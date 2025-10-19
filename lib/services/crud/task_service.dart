import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'crud_exceptions.dart';

class TasksService {
  Database? _db;
  late String _email;
  late DatabaseUser _owner;

  List<DatabaseTask> _tasks = [];

  static final TasksService _service = TasksService._sharedInstance();
  TasksService._sharedInstance() {
    _tasksStreamController = StreamController<List<DatabaseTask>>.broadcast(
      onListen:() {
        _tasksStreamController.sink.add(_tasks);
      },
    );
  }
  factory TasksService() => _service;

  late final StreamController<List<DatabaseTask>> _tasksStreamController;

  Stream<List<DatabaseTask>> get tasksStream => _tasksStreamController.stream;

  /// Task functions

  Future<void> _cacheTasks() async {
    _tasks = await getAllTask();

    _tasksStreamController.add(_tasks);
  }

  Future<DatabaseTask> createTask({required String name, required String note}) async {
    Database db = _getDatabaseOrThrow();

    // Make sure the user exists in the database with the correct ID
    final dbUser = await getUser();
    if (dbUser != _owner) throw CouldNotFindUser();

    final taskId = await db.insert(taskTable, {
      userIdColumn: _owner.id,
      nameColumn: name,
      noteColumn: note,
      isCompletedColumn: 0,
      isSyncedColumn: 0,
    });
    final task = DatabaseTask(id: taskId, userId: _owner.id, name: name, note: note);

    _tasks.add(task);
    _tasksStreamController.add(_tasks);

    return task;
  }

  Future<DatabaseTask> updateTask({required DatabaseTask task, required String name, required String note}) async {
    Database db = _getDatabaseOrThrow();

    // Make sure the task exists in the database with the correct ID
    await getTask(id: task.id);

    // Update the task in the database
    final updateCount = await db.update(taskTable, where: 'id = ?', whereArgs: [task.id], {
      nameColumn: name,
      noteColumn: note,
      isSyncedColumn: 0
    });
    if (updateCount == 0) throw CouldNotUpdateTask();

    // Update the task in the cache
    final updatedTask = await getTask(id: task.id);
    _tasks.removeWhere((task) => task.id == updatedTask.id);
    _tasks.add(updatedTask);
    _tasksStreamController.add(_tasks);
    return updatedTask;
  }

  Future<DatabaseTask> checkOrUncheckTask({required DatabaseTask task}) async {
    Database db = _getDatabaseOrThrow();

    // Make sure the task exists in the database with the correct ID
    await getTask(id: task.id);

    late final int updateCount;
    if (task.isCompleted) {
      updateCount = await db.update(taskTable, where: 'id = ?', whereArgs: [task.id], {
        isCompletedColumn: 0,
        isSyncedColumn: 0
      });
    } else {
      updateCount = await db.update(taskTable, where: 'id = ?', whereArgs: [task.id], {
        isCompletedColumn: 1,
        isSyncedColumn: 0
      });
    }

    if (updateCount == 0) throw CouldNotUpdateTask();

    // Update the task in the cache
    final updatedTask = await getTask(id: task.id);
    _tasks.removeWhere((task) => task.id == updatedTask.id);
    _tasks.add(updatedTask);
    _tasksStreamController.add(_tasks);
    return updatedTask;
  }

  Future<DatabaseTask> getTask({required int id}) async {
    Database db = _getDatabaseOrThrow();

    final tasks =  await db.query(
      taskTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id]
    );
    if (tasks.isEmpty) throw CouldNotFindTask();
    final task = DatabaseTask.fromRow(tasks.first);
    _tasks.removeWhere((task) => task.id == id);
    _tasks.add(task);
    _tasksStreamController.add(_tasks);

    return task;
  }

  Future<List<DatabaseTask>> getAllTask() async {
    Database db = _getDatabaseOrThrow();

    final tasks = await db.query(taskTable, where: 'user_id = ?', whereArgs: [_owner.id]);

    return tasks.map((taskRow) => DatabaseTask.fromRow(taskRow)).toList();
  }

  Future<void> deleteTask({required int id}) async {
    Database db = _getDatabaseOrThrow();

    final deletedTask = await db.delete(
        taskTable,
        where: 'id = ?',
        whereArgs: [id]
    );
    if (deletedTask == 0) throw CouldNotDeleteTask();
    _tasks.removeWhere((task) => task.id == id);
    _tasksStreamController.add(_tasks);
  }

  Future<int> deleteAllTasks() async {
    Database db = _getDatabaseOrThrow();
    final deletedTasks = await db.delete(taskTable, where: 'user_id = ?', whereArgs: [_owner.id]);

    _tasks = [];
    _tasksStreamController.add(_tasks);

    return deletedTasks;
  }

  Future<int> deleteCompletedTasks() async {
    Database db = _getDatabaseOrThrow();
    final deletedTasks = await db.delete(taskTable, where: '$userIdColumn = ? AND $isCompletedColumn = 1', whereArgs: [_owner.id]);

    _tasks = await getAllTask();

    _tasksStreamController.add(_tasks);

    return deletedTasks;
  }

  /// User functions

  Future<DatabaseUser> getOrCreateUser() async {
    try {
      return await getUser();
    } on CouldNotFindUser {
      return await createUser();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser() async {
    Database db = _getDatabaseOrThrow();
    
    final deletedAccount = await db.delete(userTable, where: 'email = ?', whereArgs: [_email.toLowerCase()]);
    if (deletedAccount != 1) throw CouldNotDeleteUser();
  }

  Future<DatabaseUser> createUser() async {
    Database db = _getDatabaseOrThrow();

    final results = await db.query(userTable, limit: 1, where: 'email = ?', whereArgs: [_email.toLowerCase()]);

    if (results.isNotEmpty) throw UserAlreadyExistsException();

    final userId = await db.insert(userTable, {
      emailColumn: _email.toLowerCase(),
    });

    return DatabaseUser(id: userId, email: _email);
  }

  Future<DatabaseUser> getUser() async {
    Database db = _getDatabaseOrThrow();

    final results = await db.query(userTable, limit: 1, where: 'email = ?', whereArgs: [_email.toLowerCase()]);

    if (results.isEmpty) throw CouldNotFindUser();

    return DatabaseUser.fromRow(results.first);
  }

  Future<List<DatabaseUser>> getAllUser() async {
    Database db = _getDatabaseOrThrow();

    final results = await db.query(userTable);

    if (results.isEmpty) throw CouldNotFindUser();

    return results.map((userRow) => DatabaseUser.fromRow(userRow)).toList();
  }

  /// Sync functions

  Database _getDatabaseOrThrow() {
    final db = _db;

    if (db == null) throw DatabaseNotOpenException();

    return db;
  }

  Future<void> close() async {
    if (_db == null) throw DatabaseNotOpenException();
    await _db!.close();
    _db = null;
  }

  // Open the database to start using it
  Future<void> open({required String email}) async {
    if(_db != null) throw DatabaseAlreadyOpenException();
    _email = email;
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      _db = await openDatabase(dbPath);

      // Create the database tables if they don't exist
      await _db!.execute(createUserTable);
      await _db!.execute(createTaskTable);

      _owner = await getOrCreateUser();
      dev.log("User getting is done: ${_owner.toString()}");

      await _cacheTasks();

    } on MissingPlatformDirectoryException {
      throw UnableToGetDocsDirException();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({ required this.id, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email = $email';

  @override bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;

}

class DatabaseTask {
  final int id;
  final int userId;
  final String name;
  final String note;
  bool isCompleted;
  bool isSynced;

  DatabaseTask({
    required this.id,
    required this.userId,
    required this.name,
    required this.note,
    this.isCompleted = false,
    this.isSynced = false,
  });

  DatabaseTask.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
      userId = map[userIdColumn] as int,
      name = map[nameColumn] as String,
      note = map[noteColumn] as String,
      isCompleted = (map[isCompletedColumn] as int) == 0 ? false : true,
      isSynced = (map[isSyncedColumn] as int) == 0 ? false : true;

  @override
  String toString() => 'Task, ID = $id, '
      '\nuserId = $userId, '
      '\nname = $name, '
      '\nnote = $note, '
      '\nisCompleted = $isCompleted, '
      '\nisSynced = $isSynced';

  @override bool operator ==(covariant DatabaseTask other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'tasks.db';
const taskTable = 'task';
const userTable = 'user';

const idColumn = 'id';
const emailColumn = 'email';

const userIdColumn = 'user_id';
const nameColumn = 'name';
const noteColumn = 'note';
const isCompletedColumn = 'is_done';
const isSyncedColumn = 'is_synced';

const createUserTable = '''
    CREATE TABLE IF NOT EXISTS $userTable (
      $idColumn INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      $emailColumn TEXT UNIQUE NOT NULL
    )
    ''';
const createTaskTable = '''
    CREATE TABLE IF NOT EXISTS $taskTable (
      $idColumn INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      $userIdColumn INTEGER NOT NULL,
      $nameColumn TEXT NOT NULL,
      $noteColumn TEXT NOT NULL,
      $isCompletedColumn INTEGER NOT NULL DEFAULT 0,
      $isSyncedColumn INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY($userIdColumn) REFERENCES $userTable($idColumn)
    )
  ''';