import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/sync_queue_item.dart';
import '../sync_service.dart';

class FirestoreSyncTransport implements SyncTransport {
  final FirebaseFirestore _firestore;
  final String collectionPrefix;

  FirestoreSyncTransport({
    FirebaseFirestore? firestore,
    this.collectionPrefix = 'school_secretariat',
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> push(SyncQueueItem item) async {
    final payload = jsonDecode(item.payload);
    if (payload is! Map<String, dynamic>) {
      throw const FormatException('بيانات المزامنة غير صالحة.');
    }
    if (item.entityType != 'student' &&
        item.entityType != 'attendance' &&
        item.entityType != 'grade') {
      throw UnsupportedError(
        'لا يوجد Transport للكيان ${item.entityType} حتى الآن.',
      );
    }

    final document = _firestore
        .collection('${collectionPrefix}_${item.entityType}')
        .doc(item.entityId);
    final snapshot = await document.get();
    final remoteUpdatedAt = snapshot.data()?['updated_at'];
    if (remoteUpdatedAt is Timestamp &&
        !remoteUpdatedAt.toDate().toUtc().isBefore(item.createdAt.toUtc())) {
      throw SyncConflictException(item.entityType, item.entityId);
    }

    if (item.operation == 'delete') {
      await document.set({
        'is_deleted': true,
        'updated_at': FieldValue.serverTimestamp(),
        'deleted_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return;
    }
    if (item.operation != 'upsert') {
      throw UnsupportedError('عملية المزامنة ${item.operation} غير مدعومة.');
    }

    await document.set({
      ...payload,
      'id': item.entityId,
      'is_deleted': false,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

class SyncConflictException implements Exception {
  final String entityType;
  final String entityId;

  const SyncConflictException(this.entityType, this.entityId);

  @override
  String toString() => 'تعارض في مزامنة $entityType/$entityId.';
}
