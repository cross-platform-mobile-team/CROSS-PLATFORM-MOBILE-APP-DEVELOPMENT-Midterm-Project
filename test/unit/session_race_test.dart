import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:taskflow_qa_lab/core/errors/app_failure.dart';
import 'package:taskflow_qa_lab/core/network/api_client.dart';

import 'api_client_test.dart' show login, loginData, jsonResponse, failure;

void main() {
  test(
    'wrong password after token refresh preserves the refreshed session',
    () async {
      final api = ApiClient(
        Uri.parse('http://localhost:8080'),
        client: MockClient((req) async {
          if (req.url.path.endsWith('/login')) return jsonResponse(loginData());
          if (req.url.path.endsWith('/refresh')) {
            return jsonResponse({
              'accessToken': 'b' * 43,
              'refreshToken': 's' * 43,
            });
          }
          if (req.headers['Authorization'] == 'Bearer ${'a' * 43}') {
            return failure('unauthorized', 401);
          }
          return failure('invalid_password', 401);
        }),
      );
      addTearDown(api.dispose);
      await login(api);
      await expectLater(
        api.changePassword('wrong', 'new-test-password'),
        throwsA(
          isA<AppFailure>().having((e) => e.code, 'code', 'invalid_password'),
        ),
      );
      expect(api.user?.id, 'alice');
    },
  );
  test('old logout response must not erase a newer login', () async {
    final entered = Completer<void>();
    final response = Completer<http.Response>();
    final api = ApiClient(
      Uri.parse('http://localhost:8080'),
      client: MockClient((req) async {
        if (req.url.path.endsWith('/logout')) {
          entered.complete();
          return response.future;
        }
        return jsonResponse(loginData());
      }),
    );
    addTearDown(api.dispose);
    await login(api);
    final oldLogout = expectLater(api.logout(), throwsA(isA<AppFailure>()));
    await entered.future;
    api.clearSession();
    await login(api);
    response.complete(http.Response('', 204));
    await oldLogout;
    expect(api.user?.id, 'alice');
    expect(await api.request('GET', '/v1/auth/me'), isNotEmpty);
  });
}
