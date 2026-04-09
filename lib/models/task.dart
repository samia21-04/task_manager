class Task {
  String? id;
  String name;
  bool isCompleted;
  List<String> subtasks;

  Task({
    this.id,
    required this.name,
    this.isCompleted = false,
    this.subtasks = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isCompleted': isCompleted,
      'subtasks': subtasks,
    };
  }

  factory Task.fromMap(String id, Map<String, dynamic> map) {
    return Task(
      id: id,
      name: map['name'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      subtasks: List<String>.from(map['subtasks'] ?? []),
    );
  }
}