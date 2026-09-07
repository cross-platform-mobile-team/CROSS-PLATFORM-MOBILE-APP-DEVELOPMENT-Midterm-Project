import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:taskflow_qa_lab/core/errors/app_failure.dart';
import 'package:taskflow_qa_lab/core/network/api_client.dart';
import 'package:taskflow_qa_lab/features/tasks/data/remote_task_repository.dart';
import 'package:taskflow_qa_lab/features/tasks/domain/task_item.dart';

Map<String, dynamic> loginData() => {
  'accessToken': 'a' * 43,
  'refreshToken': 'r' * 43,
  'user': {'id': 'alice', 'email': 'alice@example.test', 'name': 'Alice'},
};
http.Response jsonResponse(Object value, [int status = 200]) =>
    http.Response(jsonEncode(value), status);
http.Response failure(String code, int status) => jsonResponse({
  'error': {'code': code, 'message': code},
}, status);
Future<void> login(ApiClient api) => api
    .signIn(email: 'alice@example.test', password: 'test-only-password')
    .then((_) {});

void main() {
  test(
    'remote snapshots preserve fields, normalize timestamps and carry revision',
    () async {
      Map<String, dynamic>? sent;
      final api = ApiClient(
        Uri.parse('http://127.0.0.1:8080'),
        client: MockClient((req) async {
          if (req.url.path.endsWith('/login')) return jsonResponse(loginData());
          expect(req.headers['Authorization'], 'Bearer ${'a' * 43}');
          if (req.method == 'GET') {
            return jsonResponse({'revision': 4, 'tasks': []});
          }
          sent = jsonDecode(req.body) as Map<String, dynamic>;
          return jsonResponse({'revision': 5, 'tasks': sent!['tasks']});
        }),
      );
      addTearDown(api.dispose);
      await login(api);
      final repo = RemoteTaskRepository(api);
      expect(await repo.load(), isEmpty);
      await repo.save([
        TaskItem(
          id: 'one',
          title: 'Remote task',
          createdAt: DateTime(2026, 9, 7),
        ),
      ]);
      expect(sent!['revision'], 4);
      expect((sent!['tasks'] as List).single['createdAt'], endsWith('Z'));
      await repo.save([]);
      expect(sent!['revision'], 5);
    },
  );
  test(
    'unloaded and failed snapshot saves require explicit reload, not replay',
    () async {
      var writes = 0;
      final api = ApiClient(
        Uri.parse('http://localhost:8080'),
        client: MockClient((req) async {
          if (req.url.path.endsWith('/login')) return jsonResponse(loginData());
          if (req.method == 'GET') {
            return jsonResponse({'revision': 0, 'tasks': []});
          }
          writes++;
          return failure('conflict', 409);
        }),
      );
      addTearDown(api.dispose);
      await login(api);
      final repo = RemoteTaskRepository(api);
      await expectLater(
        repo.save([]),
        throwsA(
          isA<AppFailure>().having((e) => e.code, 'code', 'reload_required'),
        ),
      );
      await repo.load();
      await expectLater(
        repo.save([]),
        throwsA(isA<AppFailure>().having((e) => e.code, 'code', 'conflict')),
      );
      await expectLater(
        repo.save([]),
        throwsA(
          isA<AppFailure>().having((e) => e.code, 'code', 'reload_required'),
        ),
      );
      expect(writes, 1);
    },
  );
  test('concurrent expired requests share one token refresh', () async {
    var refreshes = 0, expired = 0;
    final bothExpired = Completer<void>();
    final api = ApiClient(
      Uri.parse('http://localhost:8080'),
      client: MockClient((req) async {
        if (req.url.path.endsWith('/login')) return jsonResponse(loginData());
        if (req.url.path.endsWith('/refresh')) {
          refreshes++;
          await bothExpired.future;
          return jsonResponse({
            'accessToken': 'b' * 43,
            'refreshToken': 's' * 43,
          });
        }
        if (req.headers['Authorization'] == 'Bearer ${'a' * 43}') {
          if (++expired == 2) bothExpired.complete();
          return failure('unauthorized', 401);
        }
        return jsonResponse({'revision': 1, 'tasks': []});
      }),
    );
    addTearDown(api.dispose);
    await login(api);
    await Future.wait([
      api.request('GET', '/v1/tasks/snapshot'),
      api.request('GET', '/v1/tasks/snapshot'),
    ]);
    expect(refreshes, 1);
  });
  test(
    'invalid current password does not refresh or discard the session',
    () async {
      var refreshes = 0;
      final api = ApiClient(
        Uri.parse('http://localhost:8080'),
        client: MockClient((req) async {
          if (req.url.path.endsWith('/login')) return jsonResponse(loginData());
          if (req.url.path.endsWith('/refresh')) refreshes++;
          return failure('invalid_password', 401);
        }),
      );
      addTearDown(api.dispose);
      await login(api);
      await expectLater(
        api.changePassword('wrong', 'another-test-password'),
        throwsA(isA<AppFailure>()),
      );
      expect(refreshes, 0);
      expect(api.user, isNotNull);
    },
  );
  test(
    'revoked refresh clears session and prevents further authenticated calls',
    () async {
      final api = ApiClient(
        Uri.parse('http://localhost:8080'),
        client: MockClient(
          (req) async => req.url.path.endsWith('/login')
              ? jsonResponse(loginData())
              : failure('unauthorized', 401),
        ),
      );
      addTearDown(api.dispose);
      await login(api);
      await expectLater(
        api.request('GET', '/v1/tasks/snapshot'),
        throwsA(isA<AppFailure>()),
      );
      expect(api.user, isNull);
      await expectLater(
        api.request('GET', '/v1/tasks/snapshot'),
        throwsA(isA<AppFailure>()),
      );
    },
  );
  test(
    'network failure during logout still clears local credentials',
    () async {
      final api = ApiClient(
        Uri.parse('http://localhost:8080'),
        client: MockClient((req) async {
          if (req.url.path.endsWith('/login')) return jsonResponse(loginData());
          throw http.ClientException('Disconnected');
        }),
      );
      addTearDown(api.dispose);
      await login(api);
      await expectLater(api.logout(), throwsA(isA<AppFailure>()));
      expect(api.user, isNull);
    },
  );
  test('cancelled login cannot resurrect an account', () async {
    final response = Completer<http.Response>();
    final started = Completer<void>();
    final api = ApiClient(
      Uri.parse('http://localhost:8080'),
      client: MockClient((req) {
        started.complete();
        return response.future;
      }),
    );
    addTearDown(api.dispose);
    final pending = login(api);
    await started.future;
    api.clearSession();
    final assertion = expectLater(pending, throwsA(isA<AppFailure>()));
    response.complete(jsonResponse(loginData()));
    await assertion;
    expect(api.user, isNull);
  });
  test(
    'insecure remote origin and cross-origin API routes are rejected',
    () async {
      expect(
        () => ApiClient(Uri.parse('http://example.com')),
        throwsArgumentError,
      );
      final api = ApiClient(
        Uri.parse('http://localhost:8080'),
        client: MockClient((req) async => jsonResponse(loginData())),
      );
      addTearDown(api.dispose);
      await login(api);
      await expectLater(
        api.request('GET', 'https://untrusted.example/v1/tasks'),
        throwsA(isA<AppFailure>()),
      );
    },
  );
}
