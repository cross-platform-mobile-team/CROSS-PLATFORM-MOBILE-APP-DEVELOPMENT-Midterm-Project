import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../errors/app_failure.dart';

class Account {
  const Account({required this.id, required this.email, required this.name});
  factory Account.fromJson(Map<String, dynamic> json) => Account(
    id: json['id'] as String,
    email: json['email'] as String,
    name: json['name'] as String,
  );
  final String id;
  final String email;
  final String name;
}

/// Credentials exist only in memory. Never write this object's state to logs or preferences.
class ApiClient extends ChangeNotifier {
  ApiClient(
    this.baseUri, {
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client() {
    if (!baseUri.hasAuthority ||
        baseUri.host.isEmpty ||
        baseUri.userInfo.isNotEmpty ||
        baseUri.hasQuery ||
        baseUri.hasFragment ||
        (baseUri.path.isNotEmpty && baseUri.path != '/') ||
        (baseUri.scheme != 'https' &&
            !(baseUri.scheme == 'http' &&
                [
                  'localhost',
                  '127.0.0.1',
                  '::1',
                  '10.0.2.2',
                ].contains(baseUri.host)))) {
      throw ArgumentError(
        'Use an HTTPS API origin, or HTTP on loopback for development.',
      );
    }
  }
  final Uri baseUri;
  final Duration timeout;
  final http.Client _client;
  Account? user;
  String? _accessToken;
  String? _refreshToken;
  Future<void>? _refreshing;
  int _generation = 0;
  bool _disposed = false;

  void _emit() {
    if (!_disposed) notifyListeners();
  }

  void clearSession() {
    _generation++;
    _accessToken = null;
    _refreshToken = null;
    user = null;
    _emit();
  }

  Future<http.Response> _raw(
    String method,
    String path,
    Map<String, dynamic>? body,
    String? access,
  ) async {
    final uri = baseUri.resolve(path);
    if (uri.origin != baseUri.origin || !path.startsWith('/v1/')) {
      throw const AppFailure('Invalid API route.', code: 'configuration');
    }
    final request = http.Request(method, uri);
    request.followRedirects = false;
    request.headers['Content-Type'] = 'application/json';
    if (access != null) request.headers['Authorization'] = 'Bearer $access';
    if (body != null) request.body = jsonEncode(body);
    try {
      return await _client
          .send(request)
          .then(http.Response.fromStream)
          .timeout(timeout);
    } on TimeoutException {
      throw const AppFailure(
        'The server took too long to respond. Reload before retrying a save.',
        code: 'network',
      );
    } on http.ClientException {
      throw const AppFailure(
        'Cannot reach the server. Check the connection and try again.',
        code: 'network',
      );
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.statusCode == 204) return {};
    dynamic value;
    try {
      value = jsonDecode(response.body);
    } catch (_) {
      throw const AppFailure(
        'The server returned an unreadable response.',
        code: 'protocol',
      );
    }
    if (value is! Map<String, dynamic>) {
      throw const AppFailure('Invalid server response.', code: 'protocol');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = value['error'];
      throw AppFailure(
        error is Map
            ? error['message'] as String? ?? 'Request failed.'
            : 'Request failed.',
        code: error is Map ? error['code'] as String? ?? 'unknown' : 'unknown',
      );
    }
    return value;
  }

  Future<void> _refresh() async {
    final generation = _generation;
    final refresh = _refreshToken;
    if (refresh == null) {
      throw const AppFailure('Sign in again.', code: 'unauthorized');
    }
    final response = await _raw('POST', '/v1/auth/refresh', {
      'refreshToken': refresh,
    }, null);
    if (generation != _generation) {
      throw const AppFailure(
        'Session changed. Sign in again.',
        code: 'unauthorized',
      );
    }
    if (response.statusCode == 401) clearSession();
    final data = _decode(response);
    _accessToken = data['accessToken'] as String;
    _refreshToken = data['refreshToken'] as String;
  }

  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    final generation = _generation;
    final usedToken = authenticated ? _accessToken : null;
    if (authenticated && usedToken == null) {
      throw const AppFailure('Sign in again.', code: 'unauthorized');
    }
    var response = await _raw(method, path, body, usedToken);
    if (authenticated && generation != _generation) {
      throw const AppFailure(
        'Session changed. Sign in again.',
        code: 'unauthorized',
      );
    }
    // Only expired authentication triggers refresh; a wrong current password does not.
    var refreshable = false;
    if (response.statusCode == 401) {
      try {
        refreshable =
            jsonDecode(response.body)['error']['code'] == 'unauthorized';
      } catch (_) {
        /* Malformed responses are handled by _decode. */
      }
    }
    if (authenticated && refreshable && _refreshToken != null) {
      if (_accessToken == usedToken) {
        final refreshing = _refreshing ??= _refresh();
        try {
          await refreshing;
        } finally {
          if (identical(_refreshing, refreshing)) _refreshing = null;
        }
      }
      if (generation != _generation) {
        throw const AppFailure('Sign in again.', code: 'unauthorized');
      }
      response = await _raw(method, path, body, _accessToken);
      if (generation != _generation) {
        throw const AppFailure(
          'Session changed. Sign in again.',
          code: 'unauthorized',
        );
      }
      if (response.statusCode == 401) clearSession();
    }
    return _decode(response);
  }

  Future<String?> signIn({
    required String email,
    required String password,
    String? name,
  }) async {
    final generation = _generation;
    final data = await request(
      'POST',
      name == null ? '/v1/auth/login' : '/v1/auth/register',
      authenticated: false,
      body: {'email': email, 'password': password, 'name': ?name},
    );
    if (_disposed || generation != _generation) {
      throw const AppFailure(
        'Sign-in was cancelled. Please try again.',
        code: 'unauthorized',
      );
    }
    _generation++;
    _accessToken = data['accessToken'] as String;
    _refreshToken = data['refreshToken'] as String;
    user = Account.fromJson(data['user'] as Map<String, dynamic>);
    _emit();
    return data['recoveryCode'] as String?;
  }

  Future<String> recover(String email, String code, String password) async {
    final data = await request(
      'POST',
      '/v1/auth/reset-password',
      authenticated: false,
      body: {'email': email, 'recoveryCode': code, 'newPassword': password},
    );
    return data['recoveryCode'] as String;
  }

  Future<void> updateName(String name) async {
    final data = await request('PATCH', '/v1/auth/me', body: {'name': name});
    user = Account.fromJson(data['user'] as Map<String, dynamic>);
    _emit();
  }

  Future<void> changePassword(String current, String next) async {
    await request(
      'POST',
      '/v1/auth/password',
      body: {'currentPassword': current, 'newPassword': next},
    );
    clearSession();
  }

  Future<void> deleteAccount(String current) async {
    await request('DELETE', '/v1/auth/me', body: {'currentPassword': current});
    clearSession();
  }

  Future<void> logout({bool all = false}) async {
    try {
      await request('POST', all ? '/v1/auth/logout-all' : '/v1/auth/logout');
    } finally {
      clearSession();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _client.close();
    super.dispose();
  }
}
