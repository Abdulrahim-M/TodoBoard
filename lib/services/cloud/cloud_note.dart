
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'cloud_storage_constants.dart';

@immutable
class CloudNote {

  final String documentId;
  final String ownerUserId;
  final String name;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;


  const CloudNote({
    required this.documentId,
    required this.ownerUserId,
    required this.name,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.isPinned,
  });

  factory CloudNote.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return CloudNote(
      documentId: snapshot.id,
      ownerUserId: data[ownerUserIdFieldName],
      name: data[nameFieldName],
      content: data[contentFieldName],
      createdAt: (data[createdAtFieldName] as Timestamp).toDate(),
      updatedAt: (data[updatedAtFieldName] as Timestamp).toDate(),
      isPinned: data[isPinnedFieldName],
    );
  }
}
