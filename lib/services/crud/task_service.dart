import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart' show getApplicationDocumentsDirectory;
import 'package:path/path.dart' show join;
import 'crud_exceptions.dart';

class tasksService {
  Database? _db;

  Future<DatabaseTask> createTask({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();

    // Make sure the user exists in the database with the correct ID
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) throw CouldNotFindUser();

    const name = '';
    final taskId = await db.insert(taskTable, {
      userIdColumn: owner.id,
      nameColumn: name,
      isCompletedColumn: 0,
      isSyncedColumn: 0,
    });

    return DatabaseTask(id: taskId, userId: owner.id, name: name);
  }

  Future<DatabaseTask> updateTask({required DatabaseTask task, required String name}) async {
    final db = _getDatabaseOrThrow();

    await getTask(id: task.id);

    final updateCount = await db.update(taskTable, {
      nameColumn: name,
      isSyncedColumn: 0
    });

    if (updateCount == 0) throw CouldNotUpdateTask();

    return await getTask(id: task.id);
  }

  Future<DatabaseTask> getTask({required int id}) async {
    final db = _getDatabaseOrThrow();

    final task =  await db.query(
      taskTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id]
    );
    if (task.isEmpty) throw CouldNotFindTask();

    return DatabaseTask.fromRow(task.first);
  }

  Future<Iterable<DatabaseTask>> getAllTask({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();

    final tasks = await db.query(taskTable, where: 'user_id = ?', whereArgs: [owner.id]);

    return tasks.map((taskRow) => DatabaseTask.fromRow(taskRow));
  }

  Future<void> deleteTask({required int id}) async {
    final db = _getDatabaseOrThrow();

    final deletedTask = await db.delete(
        taskTable,
        where: 'id = ?',
        whereArgs: [id]
    );
    if (deletedTask == 0) throw CouldNotDeleteTask();
  }

  Future<int> deleteAllTasks({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();
    return await db.delete(taskTable, where: 'user_id = ?', whereArgs: [owner.id]);
  }

  /// User functions

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    
    final deletedAccount = await db.delete(userTable, where: 'email = ?', whereArgs: [email.toLowerCase()]);
    if (deletedAccount != 1) throw CouldNotDeleteUser();
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();

    final results = await db.query(userTable, limit: 1, where: 'email = ?', whereArgs: [email.toLowerCase()]);

    if (results.isNotEmpty) throw UserAlreadyExistsException();

    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(id: userId, email: email);
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();

    final results = await db.query(userTable, limit: 1, where: 'email = ?', whereArgs: [email.toLowerCase()]);

    if (results.isEmpty) throw CouldNotFindUser();

    return DatabaseUser.fromRow(results.first);
  }

  Database _getDatabaseOrThrow() {
    if (_db == null) throw DatabaseNotOpenException();
    return _db!;
  }

  Future<void> close() async {
    if (_db == null) throw DatabaseNotOpenException();
    await _db!.close();
    _db = null;
  }

  Future<void> open() async {
    if(_db != null) throw DatabaseAlreadyOpenException();
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      _db = await openDatabase(dbPath);

      // Create the database tables if they don't exist
      await _db!.execute(createUserTable);
      await _db!.execute(createTaskTable);

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
  bool isCompleted;
  bool isSynced;

  DatabaseTask({
    required this.id,
    required this.userId,
    required this.name,
    this.isCompleted = false,
    this.isSynced = false,
  });

  DatabaseTask.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
      userId = map[userIdColumn] as int,
      name = map[nameColumn] as String,
      isCompleted = (map[isCompletedColumn] as int) == 0 ? false : true,
      isSynced = (map[isSyncedColumn] as int) == 0 ? false : true;

  @override
  String toString() => 'Task, ID = $id, '
      '\nuserId = $userId, '
      '\nname = $name, '
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
      $isCompletedColumn INTEGER NOT NULL DEFAULT 0,
      $isSyncedColumn INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY($userIdColumn) REFERENCES $userTable($idColumn)
    )
  ''';