import 'package:flutter/foundation.dart';
import 'package:virtual_pa/model/task.dart';

class Tasks with ChangeNotifier {
  List<Task> _list = [];

  List<Task> get list => _list;

  void addTasks(List<Task> tasks, {bool shouldNotify = true}) {
    _list = tasks;
    if (shouldNotify) notifyListeners();
  }

  void addTask(Task task, {bool shouldNotify = true}) {
    _list.add(task);
    if (shouldNotify) notifyListeners();
  }

  void deleteTask(Task task, {bool shouldNotify = true}) {
    _list.remove(task);
  }

  List<Task> getSortByDateTask({List<Task>? tasks, bool isAsec = true}) {
    final list = tasks ?? _list;
    list.sort((Task a, Task b) {
      return isAsec ? a.compareTo(b) : b.compareTo(a);
    });

    return list;
  }

  List<Task> getUrgentTask({bool isAsec = true}) {
    final list = _list.where((task) => task.urgent).toList();
    return getSortByDateTask(tasks: list);
  }
}
