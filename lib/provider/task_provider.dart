import 'package:flutter/material.dart';
import 'package:todo/database/database_helper.dart';
import 'package:todo/model/task_model.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Task> get tasks => _tasks;

  TaskProvider() {
    loadTasks();
  }

 Future<void> loadTasks() async {
  _tasks = await _dbHelper.getTasks(); // Fetch tasks from the database
  print('Tasks loaded: ${_tasks.map((task) => task.title).toList()}'); // Debugging
  notifyListeners(); // Notify listeners to update the UI
}


  Future<void> addTask(String title) async {
  final task = Task(title: title);
  await _dbHelper.insertTask(task);
  await loadTasks();
}


  Future<void> toggleTaskCompletion(Task task) async {
    task.isCompleted = !task.isCompleted;
    await _dbHelper.updateTask(task);
    await loadTasks();
  }
  Future<void> deleteTask(Task task) async {
  await _dbHelper.deleteTask(task.id!); // Ensure the task ID is not null
  await loadTasks(); // Refresh the task list
}

}
