import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rpg_life_app/services/cloud/cloud_storage_constants.dart';
import 'package:rpg_life_app/services/cloud/cloud_storage_exceptions.dart';
import 'package:rpg_life_app/services/cloud/cloud_note.dart';

import 'cloud_task.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');
  final tasks = FirebaseFirestore.instance.collection('tasks');

  /// Singleton pattern

  static final FirebaseCloudStorage _service = FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _service;

  /// Stream functions

  Stream<Iterable<CloudTask>> allTasks({required String ownerUserId}) =>
    tasks.snapshots()
        .map((event) => event.docs
        .map((doc) => CloudTask.fromSnapshot(doc))
        .where((task) => task.ownerUserId == ownerUserId
    ));

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
      notes.snapshots()
          .map((event) => event.docs
          .map((doc) => CloudNote.fromSnapshot(doc))
          .where((task) => task.ownerUserId == ownerUserId
      ));

  /// CRUD functions

  void createTask({required String ownerUserId}) async {
    await tasks.add({
      ownerUserIdFieldName: ownerUserId,
      nameFieldName: '',
      noteFieldName: '',
      createdAtFieldName: FieldValue.serverTimestamp(),
      updatedAtFieldName: FieldValue.serverTimestamp(),
      isTaskCompletedFieldName: false,
    });
  }

  void createNote({required String ownerUserId}) async {
    await notes.add({
      ownerUserIdFieldName: ownerUserId,
      nameFieldName: '',
      contentFieldName: '',
      createdAtFieldName: FieldValue.serverTimestamp(),
      updatedAtFieldName: FieldValue.serverTimestamp(),
      isPinnedFieldName: false,
    });
  }

  Future<Iterable<CloudTask>> getTasks({required String ownerUserId}) async {
    try {
      return await tasks.where(
          ownerUserIdFieldName,
          isEqualTo: ownerUserId
      ).get().then((value) =>
          value.docs.map((doc) =>
              CloudTask (
                documentId: doc.id,
                ownerUserId: doc.data()[ownerUserIdFieldName],
                name: doc.data()[nameFieldName],
                note: doc.data()[noteFieldName],
                isCompleted: doc.data()[isTaskCompletedFieldName],
                createdAt: (doc.data()[createdAtFieldName] as Timestamp).toDate(),
                updatedAt: (doc.data()[updatedAtFieldName] as Timestamp).toDate(),
                dueDate: (doc.data()[dueDateFieldName] as Timestamp?)?.toDate(),
                priority: doc.data()[priorityFieldName],
                category: doc.data()[categoryFieldName],
              )
          )
      );
    }
    catch (e) {
      throw CouldNotGetAllTasksException();
    }
  }

  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      return await notes.where(
          ownerUserIdFieldName,
          isEqualTo: ownerUserId
      ).get().then((value) =>
          value.docs.map((doc) =>
              CloudNote (
                documentId: doc.id,
                ownerUserId: doc.data()[ownerUserIdFieldName],
                name: doc.data()[nameFieldName],
                content: doc.data()[contentFieldName],
                createdAt: (doc.data()[createdAtFieldName] as Timestamp).toDate(),
                updatedAt: (doc.data()[updatedAtFieldName] as Timestamp).toDate(),
                isPinned: doc.data()[isPinnedFieldName],
              )
          )
      );
    }
    catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  Future<void> updateTask({required String documentId, required String name, required String note,}) async {
    try {
      await tasks.doc(documentId).update({
        nameFieldName: name,
        noteFieldName: note,
        updatedAtFieldName: FieldValue.serverTimestamp(),
      });
    }
    catch (e) {
      throw CouldNotUpdateTaskException();
    }
  }

  Future<void> updateNote({required String documentId, required String name, required String note,}) async {
    try {
      await notes.doc(documentId).update({
        nameFieldName: name,
        contentFieldName: note,
        updatedAtFieldName: FieldValue.serverTimestamp(),
      });
    }
    catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<void> deleteTask({required String documentId}) async {
    try {
      await tasks.doc(documentId).delete();
    }
    catch (e) {
      throw CouldNotDeleteTaskException();
    }
  }

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    }
    catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }
}
