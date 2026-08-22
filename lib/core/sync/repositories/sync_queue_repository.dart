import 'dart:convert';

import '../../../database/database_helper.dart';
import '../models/sync_queue_item.dart';

class SyncQueueRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> enqueue({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    final database = await _databaseHelper.database;
    return database.insert('sync_queue', {
      'entity_type': entityType,
      'entity_id': entityId,
      'operation': operation,
      'payload': jsonEncode(payload),
      'status': 'pending',
      'attempts': 0,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<List<SyncQueueItem>> pendingItems({int limit = 50}) async {
    final database = await _databaseHelper.database;
    final rows = await database.query(
      'sync_queue',
      where: "status IN ('pending', 'failed')",
      orderBy: 'created_at ASC, id ASC',
      limit: limit,
    );
    return rows.map(SyncQueueItem.fromMap).toList();
  }

  Future<void> markSynced(int id) async {
    final database = await _databaseHelper.database;
    await database.update(
      'sync_queue',
      {'status': 'synced', 'last_error': null},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markFailed(int id, Object error) async {
    final database = await _databaseHelper.database;
    await database.rawUpdate(
      '''UPDATE sync_queue
         SET status = 'failed', attempts = attempts + 1, last_error = ?
         WHERE id = ?''',
      [error.toString(), id],
    );
  }

  Future<int> pendingCount() async {
    final database = await _databaseHelper.database;
    final rows = await database.rawQuery(
      "SELECT COUNT(*) AS count FROM sync_queue WHERE status IN ('pending', 'failed')",
    );
    return (rows.first['count'] as int?) ?? 0;
  }
}
