import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/model/task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'tasks.db');
  print('Database path: $path'); // Debugging
  return await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE tasks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          isCompleted INTEGER
        )
      ''');
    },
  );
}


  Future<void> insertTask(Task task) async {
  final db = await database;
  final id = await db.insert(
    'tasks',
    task.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
  print('Inserted task with ID: $id'); // Debugging
}


  Future<List<Task>> getTasks() async {
  final db = await database;

  // Fetch all rows from the `tasks` table
  final List<Map<String, dynamic>> maps = await db.query('tasks');

  // Map the results to a list of Task objects
  return List.generate(
    maps.length,
    (i) => Task(
      id: maps[i]['id'],
      title: maps[i]['title'],
      isCompleted: maps[i]['isCompleted'] == 1,
    ),
  );
}

  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update(
      'tasks',
      {'title': task.title, 'isCompleted': task.isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
}
