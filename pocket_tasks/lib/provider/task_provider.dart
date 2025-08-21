import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';

enum TaskFilter { all, active, done }

class TaskProvider extends ChangeNotifier {
  static const _storageKey = "pocket_tasks_v1";

  final List<Task> _tasks = [];
  String _query = "";
  int get totalCount => _tasks.length;
  int get completedCount => _tasks.where((t) => t.done).length;
  double get progress => totalCount == 0 ? 0 : completedCount / totalCount;

  TaskFilter _filter = TaskFilter.all;

  List<Task> get tasks {
    var filtered = _query.isEmpty
        ? _tasks
        : _tasks
            .where((t) => t.title.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    switch (_filter) {
      case TaskFilter.active:
        return filtered.where((t) => !t.done).toList();
      case TaskFilter.done:
        return filtered.where((t) => t.done).toList();
      case TaskFilter.all:
      default:
        return filtered;
    }
  }

  Future<void> insertAt(Task task, int index) async {
    _tasks.insert(index.clamp(0, _tasks.length), task);
    await _save();
  }

  TaskFilter get filter => _filter;

  void setQuery(String query) {
    _query = query;
    notifyListeners();
  }

  void setFilter(TaskFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  TaskProvider() {
    loadTasks();
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);

    if (data != null) {
      _tasks.clear();
      _tasks.addAll(Task.decode(data));
      notifyListeners();
    }
  }

  Future<void> addTask(String title) async {
    if (title.trim().isEmpty) return;
    final task = Task(
      id: const Uuid().v4(),
      title: title,
      createdAt: DateTime.now(),
    );
    _tasks.add(task);
    await _save();
  }

  Future<void> toggleTask(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(done: !_tasks[index].done);
      await _save();
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, Task.encode(_tasks));
    notifyListeners();
  }
}
