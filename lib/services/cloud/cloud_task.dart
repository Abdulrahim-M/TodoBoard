
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'cloud_storage_constants.dart';

@immutable
class CloudTask {

  final String documentId;
  final String ownerUserId;
  final String name;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCompleted;
  final DateTime? dueDate;
  final String? priority;
  final String? category;



  const CloudTask({
    required this.documentId,
    required this.ownerUserId,
    required this.name,
    required this.note,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.priority,
    this.category,
  });

  factory CloudTask.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return CloudTask(
        documentId: snapshot.id,
        ownerUserId: data[ownerUserIdFieldName],
        name: data[nameFieldName],
        note: data[noteFieldName],
        createdAt: (data[createdAtFieldName] as Timestamp).toDate(),
        updatedAt: (data[updatedAtFieldName] as Timestamp).toDate(),
        dueDate: (data[dueDateFieldName] as Timestamp?)?.toDate(),
        isCompleted: data[isTaskCompletedFieldName],
        priority: data[priorityFieldName],
        category: data[categoryFieldName]);
  }


}
