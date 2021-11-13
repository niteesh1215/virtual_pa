enum TaskStatus { completed, started, queued }

class Task {
  String? taskId;
  String taskString;
  List<Map<String, dynamic>> keywordMappings;
  TaskStatus taskStatus;
  Task({
    required this.taskString,
    required this.keywordMappings,
    this.taskStatus = TaskStatus.queued,
  });
}
