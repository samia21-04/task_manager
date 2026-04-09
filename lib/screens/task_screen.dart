import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TextEditingController _taskController = TextEditingController();
  final TaskService _taskService = TaskService();

  String _searchQuery = '';

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  Future<void> _addTask() async {
    final title = _taskController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task title cannot be empty'),
        ),
      );
      return;
    }

    final task = Task(
      title: title,
      isCompleted: false,
      subtasks: [],
      createdAt: DateTime.now(),
    );

    await _taskService.addTask(task);

    setState(() {
      _taskController.clear();
    });
  }

  Future<void> _showDeleteDialog(String taskId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _taskService.deleteTask(taskId);
    }
  }

  Future<void> _showAddSubtaskDialog(Task task) async {
    final TextEditingController subtaskController = TextEditingController();

    final subtask = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Subtask'),
          content: TextField(
            controller: subtaskController,
            decoration: const InputDecoration(
              hintText: 'Enter subtask',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, subtaskController.text.trim());
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (subtask != null && subtask.isNotEmpty) {
      final updatedSubtasks = List<String>.from(task.subtasks)..add(subtask);

      final updatedTask = task.copyWith(
        subtasks: updatedSubtasks,
      );

      await _taskService.updateTask(updatedTask);
    }

    subtaskController.dispose();
  }

  Future<void> _removeSubtask(Task task, String subtask) async {
    final updatedSubtasks = List<String>.from(task.subtasks)..remove(subtask);

    final updatedTask = task.copyWith(
      subtasks: updatedSubtasks,
    );

    await _taskService.updateTask(updatedTask);
  }

  Future<void> _toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
    );

    await _taskService.updateTask(updatedTask);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _taskController,
              decoration: const InputDecoration(
                labelText: 'Enter a task',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _addTask(),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addTask,
                child: const Text('Add Task'),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search tasks',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase().trim();
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<Task>>(
                stream: _taskService.streamTasks(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Something went wrong while loading tasks.'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final allTasks = snapshot.data ?? [];

                  final tasks = allTasks.where((task) {
                    return task.title.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (allTasks.isEmpty) {
                    return const Center(
                      child: Text('No tasks yet — add one above!'),
                    );
                  }

                  if (tasks.isEmpty) {
                    return const Center(
                      child: Text('No matching tasks found.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ExpansionTile(
                          leading: Checkbox(
                            value: task.isCompleted,
                            onChanged: (_) => _toggleTaskCompletion(task),
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          subtitle: Text(
                            'Subtasks: ${task.subtasks.length}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              if (task.id != null) {
                                _showDeleteDialog(task.id!);
                              }
                            },
                          ),
                          children: [
                            if (task.subtasks.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('No subtasks yet'),
                                ),
                              ),
                            ...task.subtasks.map(
                              (subtask) => ListTile(
                                title: Text(subtask),
                                trailing: IconButton(
                                  icon: const Icon(Icons.remove_circle),
                                  onPressed: () => _removeSubtask(task, subtask),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                                bottom: 12,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: ElevatedButton(
                                  onPressed: () => _showAddSubtaskDialog(task),
                                  child: const Text('Add Subtask'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}