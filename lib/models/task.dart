import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String? id;
  final String title;
  final bool isCompleted;
  final List<String> subtasks;
  final DateTime createdAt;

  Task({
    this.id,
    required this.title,
    required this.isCompleted,
    required this.subtasks,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isCompleted': isCompleted,
      'subtasks': subtasks,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Task.fromMap(String id, Map<String, dynamic> map) {
    final createdAtValue = map['createdAt'];

    return Task(
      id: id,
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      subtasks: List<String>.from(map['subtasks'] ?? []),
      createdAt: createdAtValue is Timestamp
          ? createdAtValue.toDate()
          : DateTime.now(),
    );
  }

  Task copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    List<String>? subtasks,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      subtasks: subtasks ?? this.subtasks,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}