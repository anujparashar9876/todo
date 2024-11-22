import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/database/database_helper.dart';
import 'package:todo/provider/task_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbHelper = DatabaseHelper();

  // Fetch Test
  final tasks = await dbHelper.getTasks();
  print('Tasks: ${tasks.map((t) => t.title).toList()}');
  runApp(
    ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TaskListScreen(),
    );
  }
}

class TaskListScreen extends StatelessWidget {
  final TextEditingController _taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      labelText: 'Add a task',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    if (_taskController.text.isNotEmpty) {
                      await taskProvider.addTask(_taskController.text);
                      _taskController.clear();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: taskProvider.loadTasks(),
              builder: (context, snapshot) {
                return ListView.builder(
                  itemCount: taskProvider.tasks.length,
                  itemBuilder: (context, index) {
                    final task = taskProvider.tasks[index];
                    return Dismissible(
                      key: Key(task.id.toString()),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        taskProvider
                            .deleteTask(task); // Delete task when dismissed
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${task.title} deleted')),
                        );
                      },
                      child: ListTile(
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        trailing: Checkbox(
                          value: task.isCompleted,
                          onChanged: (value) {
                            taskProvider.toggleTaskCompletion(task);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
