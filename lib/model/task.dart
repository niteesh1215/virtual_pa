import 'package:jiffy/jiffy.dart';
import 'package:virtual_pa/model/registered_contact.dart';

enum TaskStatus { completed, started, queued }

class Task implements Comparable<Task> {
  String? taskId;
  String? byUserId;
  String taskString;
  String? atUserId;
  RegisteredContact? registeredContact;
  DateTime? completeBy;
  bool urgent;
  TaskStatus taskStatus;
  DateTime? timeAdded;
  Task({
    this.taskId,
    required this.taskString,
    this.byUserId,
    this.atUserId,
    this.completeBy,
    this.urgent = false,
    this.taskStatus = TaskStatus.queued,
    this.registeredContact,
    this.timeAdded,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task &&
          runtimeType == other.runtimeType &&
          taskId == other.taskId;

  @override
  int get hashCode => taskId.hashCode;

  @override
  int compareTo(Task other) {
    if (completeBy == null || other.completeBy == null) {
      return -1;
    }
    if (completeBy!.isBefore(other.completeBy!)) {
      return -1;
    } else if (completeBy!.isAfter(other.completeBy!)) {
      return 1;
    } else {
      return 0;
    }
  }

  factory Task.fromJson(Map<String, dynamic> data) {
    return Task(
      taskId: data['_id'],
      taskString: data['taskString'],
      byUserId: data['byuserId'],
      atUserId: data['atuserId'],
      completeBy: Jiffy(data['completeBy'], 'dd-MM-yyyy-h:mm:ss a').dateTime,
      urgent: data['urgent'],
      taskStatus: getTaskStatus(data['status']),
      timeAdded: data['timeAdded'] != null
          ? Jiffy(data['timeAdded'], 'dd-MM-yyyy-h:mm:ss a').dateTime
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "byuserId": byUserId,
      "atuserId": atUserId,
      "taskString": taskString,
      "completeBy": Jiffy(completeBy).format('dd-MM-yyyy-h:mm:ss a'),
      "urgent": urgent,
      "status": taskStatus.toString(),
      "timeAdded": Jiffy().format('dd-MM-yyyy-h:mm:ss a')
    };
  }

  static TaskStatus getTaskStatus(String status) {
    switch (status) {
      case 'TaskStatus.queued':
        return TaskStatus.queued;
      case 'TaskStatus.completed':
        return TaskStatus.completed;
      case 'TaskStatus.started':
        return TaskStatus.started;
    }
    return TaskStatus.completed;
  }

  @override
  String toString() {
    return 'Task{taskId: $taskId, byUserId: $byUserId, taskString: $taskString, atUserId: $atUserId, registeredContact: $registeredContact, completeBy: $completeBy, urgent: $urgent, taskStatus: $taskStatus, timeAdded: $timeAdded}';
  }
}
