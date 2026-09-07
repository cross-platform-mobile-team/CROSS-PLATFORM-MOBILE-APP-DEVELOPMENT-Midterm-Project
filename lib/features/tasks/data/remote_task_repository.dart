import '../../../core/errors/app_failure.dart';
import '../../../core/network/api_client.dart';
import '../domain/task_item.dart';
import '../domain/task_repository.dart';

class RemoteTaskRepository implements TaskRepository {
  RemoteTaskRepository(this.api);
  final ApiClient api;
  int? _revision;
  @override
  Future<List<TaskItem>> load() async {
    final data = await api.request('GET', '/v1/tasks/snapshot');
    final tasks = (data['tasks'] as List<dynamic>)
        .map((value) => TaskItem.fromJson(value as Map<String, dynamic>))
        .toList();
    _revision = data['revision'] as int;
    return tasks;
  }

  @override
  Future<void> save(List<TaskItem> tasks) async {
    if (_revision == null) {
      throw const AppFailure(
        'Reload tasks before saving. The server state is not confirmed.',
        code: 'reload_required',
      );
    }
    try {
      final data = await api.request(
        'PUT',
        '/v1/tasks/snapshot',
        body: {
          'revision': _revision,
          'tasks': tasks
              .map(
                (task) => {
                  ...task.toJson(),
                  'createdAt': task.createdAt.toUtc().toIso8601String(),
                },
              )
              .toList(),
        },
      );
      _revision = data['revision'] as int;
    } catch (_) {
      // A timed-out response may still have committed. Never blindly replay a snapshot.
      _revision = null;
      rethrow;
    }
  }
}
