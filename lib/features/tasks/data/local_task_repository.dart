import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/task_item.dart';
import '../domain/task_repository.dart';

class LocalTaskRepository implements TaskRepository {
  LocalTaskRepository({
    SharedPreferencesAsync? preferences,
    this.key = storageKey,
  }) : _preferences = preferences ?? SharedPreferencesAsync();
  final SharedPreferencesAsync _preferences;
  final String key;
  static const storageKey = 'taskflow.tasks.v1';
  @override
  Future<List<TaskItem>> load() async {
    final raw = await _preferences.getString(key);
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>)
        .map((item) => TaskItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> save(List<TaskItem> tasks) => _preferences.setString(
    key,
    jsonEncode(tasks.map((task) => task.toJson()).toList()),
  );
}
