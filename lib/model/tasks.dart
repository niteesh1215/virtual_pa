import 'package:flutter/foundation.dart';
import 'package:virtual_pa/controller/api_end_points/task_api_controller.dart';
import 'package:virtual_pa/model/l_response.dart';
import 'package:virtual_pa/model/task.dart';

class Tasks with ChangeNotifier {
  List<Task> _list = [];
  List<Task> _copyList = [];
  List<Task> get list => _list;
  bool _isTaskLoading = false;
  bool _showForMeTask = true;
  bool _isAscendingOrder = true;
  bool _showOnlyUrgent = false;

  String? userId;

  bool get isTaskLoading => _isTaskLoading;

  set isTaskLoading(bool loading) {
    _isTaskLoading = loading;
    notifyListeners();
  }

  bool get showForMeTask => _showForMeTask;

  set showForMeTask(bool value) {
    _showForMeTask = value;
    notifyListeners();
    loadTasks();
  }

  bool get isAscendingOrder => _isAscendingOrder;

  set isAscendingOrder(bool value) {
    _isAscendingOrder = value;
    getSortByDateTask(isAsec: value);
    notifyListeners();
  }

  bool get showOnlyUrgent => _showOnlyUrgent;

  set showOnlyUrgent(bool value) {
    if (_isTaskLoading) return;
    _showOnlyUrgent = value;
    if (_showOnlyUrgent) {
      _copyList = List<Task>.from(_list);
      _filterUrgent();
    } else {
      _list = List<Task>.from(_copyList);
      _copyList = [];
    }
    notifyListeners();
  }

  void _filterUrgent() {
    final tempList = List<Task>.from(_list);
    for (Task task in tempList) {
      if (!task.urgent) {
        _list.remove(task);
      }
    }
  }

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
    _list.sort((Task a, Task b) {
      return isAsec ? a.compareTo(b) : b.compareTo(a);
    });
    return _list;
  }

  List<Task> getUrgentTask({bool isAsec = true}) {
    final list = _list.where((task) => task.urgent).toList();
    return getSortByDateTask(tasks: list);
  }

  void loadTasks({bool shouldNotifyListeners = true}) async {
    _showOnlyUrgent = false;
    _list = [];
    if (shouldNotifyListeners) {
      isTaskLoading = true;
    } else {
      _isTaskLoading = true;
    }
    final TaskApiController taskApiController = TaskApiController();
    LResponse<List<Task>?> lResponse = await taskApiController
        .retrieveTask(userId!, getForMeTask: showForMeTask);

    if (lResponse.data != null && lResponse.data!.isNotEmpty) {
      addTasks(lResponse.data!);
    }

    isTaskLoading = false;
  }
}
