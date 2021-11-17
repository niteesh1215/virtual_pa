import 'package:jiffy/jiffy.dart';
import 'package:virtual_pa/model/registered_contact.dart';

enum TaskStatus { completed, started, queued }

class Task implements Comparable<Task> {
  String? taskId;
  String taskString;
  String? atUserId;
  RegisteredContact? registeredContact;
  //dd-MM-yyy format
  String? completeBy;
  bool urgent;
  TaskStatus taskStatus;
  Task({
    this.taskId,
    required this.taskString,
    this.atUserId,
    this.completeBy,
    this.urgent = false,
    this.taskStatus = TaskStatus.queued,
    this.registeredContact,
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
  String toString() {
    return 'Task{taskId: $taskId, taskString: $taskString, atUserId: $atUserId, completeBy: $completeBy, urgent: $urgent, taskStatus: $taskStatus}';
  }

  @override
  int compareTo(Task other) {
    if (completeBy == null || other.completeBy == null) {
      return -1;
    }
    final aDate = Jiffy(completeBy, 'dd-MM-yyyy');
    final bDate = Jiffy(other.completeBy, 'dd-MM-yyyy');
    if (aDate.isBefore(bDate)) {
      return -1;
    } else if (aDate.isAfter(bDate)) {
      return 1;
    } else {
      return 0;
    }
  }
}
