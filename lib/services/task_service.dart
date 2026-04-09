import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class TaskService {
  final CollectionReference _tasksCollection =
      FirebaseFirestore.instance.collection('tasks');

  Future<void> addTask(Task task) async {
    await _tasksCollection.add(task.toMap());
  }

  Future<void> updateTask(Task task) async {
    if (task.id == null) return;
    await _tasksCollection.doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
  }

  Stream<List<Task>> streamTasks() {
    return _tasksCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }
}