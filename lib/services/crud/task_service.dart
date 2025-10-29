import 'dart:async';

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
  List<DatabaseNote> _notes = [];

  static final TasksService _service = TasksService._sharedInstance();
  TasksService._sharedInstance() {
    _tasksStreamController = StreamController<List<DatabaseTask>>.broadcast(
      onListen:() {
        _tasksStreamController.sink.add(_tasks);
      },
    );
    _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
      onListen:() {
        _notesStreamController.sink.add(_notes);
      },
    );
  }
  factory TasksService() => _service;

  late final StreamController<List<DatabaseTask>> _tasksStreamController;
  late final StreamController<List<DatabaseNote>> _notesStreamController;

  Stream<List<DatabaseTask>> get tasksStream => _tasksStreamController.stream;
  Stream<List<DatabaseNote>> get notesStream => _notesStreamController.stream;

  /// Task functions

  Future<void> _cacheTasks() async {
    _tasks = await getAllTasks();

    _tasksStreamController.add(_tasks);
  }

  Future<DatabaseTask> createTask({required String name, required String note}) async {
    Database db = _getDatabaseOrThrow();

    // Make sure the user exists in the database with the correct ID
    final dbUser = await getUser();
    if (dbUser != _owner) throw CouldNotFindUser();

    final date = DateTime.now();

    final taskId = await db.insert(taskTable, {
      userIdColumn: _owner.id,
      nameColumn: name,
      noteColumn: note,
      isCompletedColumn: 0,
      isSyncedColumn: 0,
      createdAtColumn: date.millisecondsSinceEpoch,
      updatedAtColumn: date.millisecondsSinceEpoch,
      dueDateColumn: null,
      priorityColumn: null,
      categoryColumn: null,
    });

    final task = DatabaseTask(id: taskId, userId: _owner.id, name: name, note: note, createdAt: date, updatedAt: date);

    _tasks.add(task);
    _tasksStreamController.add(_tasks);

    return task;
  }

  Future<DatabaseTask> updateTask({required DatabaseTask task, required String name, required String note}) async {
    Database db = _getDatabaseOrThrow();

    // Make sure the task exists in the database with the correct ID
    await getTask(id: task.id);

    final date = DateTime.now();

    // Update the task in the database
    final updateCount = await db.update(taskTable, where: 'id = ?', whereArgs: [task.id], {
      nameColumn: name,
      noteColumn: note,
      updatedAtColumn: date.millisecondsSinceEpoch,
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

  Future<List<DatabaseTask>> getAllTasks() async {
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

    _tasks = await getAllTasks();

    _tasksStreamController.add(_tasks);

    return deletedTasks;
  }

  /// Note functions

  Future<void> _cacheNotes() async {
    _notes = await getAllNotes();

    _notesStreamController.add(_notes);
  }

  Future<DatabaseNote> createNote({required String name, required String content}) async {
    Database db = _getDatabaseOrThrow();

    // Make sure the user exists in the database with the correct ID
    final dbUser = await getUser();
    if (dbUser != _owner) throw CouldNotFindUser();

    final date = DateTime.now();

    final noteId = await db.insert(noteTable, {
      userIdColumn: _owner.id,
      nameColumn: name,
      contentColumn: content,
      isSyncedColumn: 0,
      createdAtColumn: date.millisecondsSinceEpoch,
      updatedAtColumn: date.millisecondsSinceEpoch,
    });
    final note = DatabaseNote(id: noteId, userId: _owner.id, name: name, content: content, createdAt: date, updatedAt: date);

    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

  Future<DatabaseNote> pinOrUnpinNote({required DatabaseNote note}) async {
    Database db = _getDatabaseOrThrow();

    // Make sure the task exists in the database with the correct ID
    await getNote(id: note.id);

    late final int updateCount;
    if (note.isPinned) {
      updateCount = await db.update(noteTable, where: 'id = ?', whereArgs: [note.id], {
        isPinnedColumn: 0,
        isSyncedColumn: 0
      });
    } else {
      updateCount = await db.update(noteTable, where: 'id = ?', whereArgs: [note.id], {
        isPinnedColumn: 1,
        isSyncedColumn: 0
      });
    }

    if (updateCount == 0) throw CouldNotUpdateTask();

    // Update the task in the cache
    final updatedNote = await getNote(id: note.id);
    _notes.removeWhere((note) => note.id == updatedNote.id);
    _notes.add(updatedNote);
    _notesStreamController.add(_notes);
    return updatedNote;
  }

  Future<DatabaseNote> updateNote({required DatabaseNote note, required String name, required String content}) async {
    Database db = _getDatabaseOrThrow();

    // Make sure the Note exists in the database with the correct ID
    await getNote(id: note.id);

    final date = DateTime.now();

    // Update the Note in the database
    final updateCount = await db.update(noteTable, where: 'id = ?', whereArgs: [note.id], {
      nameColumn: name,
      contentColumn: content,
      updatedAtColumn: date.millisecondsSinceEpoch,
      isSyncedColumn: 0
    });
    if (updateCount == 0) throw CouldNotUpdateNote();

    // Update the Note in the cache
    final updatedNote = await getNote(id: note.id);
    _notes.removeWhere((note) => note.id == updatedNote.id);
    _notes.add(updatedNote);
    _notesStreamController.add(_notes);
    return updatedNote;
  }

  Future<DatabaseNote> getNote({required int id}) async {
    Database db = _getDatabaseOrThrow();

    final notes =  await db.query(
        noteTable,
        limit: 1,
        where: 'id = ?',
        whereArgs: [id]
    );
    if (notes.isEmpty) throw CouldNotFindNote();
    final note = DatabaseNote.fromRow(notes.first);
    _notes.removeWhere((note) => note.id == id);
    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

  Future<List<DatabaseNote>> getAllNotes() async {
    Database db = _getDatabaseOrThrow();

    final notes = await db.query(noteTable, where: 'user_id = ?', whereArgs: [_owner.id]);

    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow)).toList();
  }

  Future<void> deleteNote({required int id}) async {
    Database db = _getDatabaseOrThrow();

    final deletedNote = await db.delete(
        noteTable,
        where: 'id = ?',
        whereArgs: [id]
    );
    if (deletedNote == 0) throw CouldNotDeleteNote();
    _notes.removeWhere((note) => note.id == id);
    _notesStreamController.add(_notes);
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
      await _db!.execute(createUserTable);;
      await _db!.execute(createTaskTable);
      await _db!.execute(createNoteTable);

      _owner = await getOrCreateUser();

      await _cacheTasks();
      await _cacheNotes();

    } on MissingPlatformDirectoryException {
      throw UnableToGetDocsDirException();
    }
  }
}



/// Database classes

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
  final DateTime createdAt;
  final DateTime updatedAt;
  bool isCompleted;
  final DateTime? dueDate;
  final String? priority;
  final String? category;
  bool isSynced;

  DatabaseTask({
    required this.id,
    required this.userId,
    required this.name,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
    this.isCompleted = false,
    this.isSynced = false,
    this.dueDate,
    this.priority,
    this.category,
  });

  DatabaseTask.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
      userId = map[userIdColumn] as int,
      name = map[nameColumn] as String,
      note = map[noteColumn] as String,
      isCompleted = !((map[isCompletedColumn] as int) == 0),
      isSynced = !((map[isSyncedColumn] as int) == 0),
      createdAt = DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt = DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      dueDate = map['due_date'] != null ? DateTime.fromMillisecondsSinceEpoch(map['due_date'] as int) : null,
      priority = map['priority'] != null ? map['priority'] as String : null,
      category = map['category'] != null ? map['category'] as String : null;

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

class DatabaseNote {
  final int id;
  final int userId;
  final String name;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  bool isSynced;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.name,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.isPinned = false,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        name = map[nameColumn] as String,
        content = map[contentColumn] as String,
        isSynced = !((map[isSyncedColumn] as int) == 0),
        createdAt = DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
        updatedAt = DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
        isPinned = !((map[isPinnedColumn] as int) == 1);

  @override
  String toString() => 'Task, ID = $id, '
      '\nuserId = $userId, '
      '\nname = $name, '
      '\nnote = $content, '
      '\nisSynced = $isSynced';

  @override bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'tasks.db';
const taskTable = 'task';
const noteTable = 'note';
const userTable = 'user';

const idColumn = 'id';
const emailColumn = 'email';

const userIdColumn = 'user_id';
const nameColumn = 'name';
const noteColumn = 'note';
const createdAtColumn = 'created_at';
const updatedAtColumn = 'updated_at';
const dueDateColumn = 'due_date';
const isCompletedColumn = 'is_done';
const isSyncedColumn = 'is_synced';
const priorityColumn = 'priority';
const categoryColumn = 'category';
const isPinnedColumn = 'is_pinned';
const contentColumn = 'content';

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
    $createdAtColumn INTEGER NOT NULL,
    $updatedAtColumn INTEGER NOT NULL,
    $dueDateColumn INTEGER,
    $priorityColumn TEXT,
    $categoryColumn TEXT,
    FOREIGN KEY($userIdColumn) REFERENCES $userTable($idColumn)
  )
''';
const createNoteTable = '''
  CREATE TABLE IF NOT EXISTS $noteTable (
    $idColumn INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    $userIdColumn INTEGER NOT NULL,
    $nameColumn TEXT NOT NULL,
    $contentColumn TEXT NOT NULL,
    $isPinnedColumn INTEGER NOT NULL DEFAULT 0,
    $isSyncedColumn INTEGER NOT NULL DEFAULT 0,
    $createdAtColumn INTEGER NOT NULL,
    $updatedAtColumn INTEGER NOT NULL,
    FOREIGN KEY($userIdColumn) REFERENCES $userTable($idColumn)
  )
''';