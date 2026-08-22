import 'dart:convert';

import 'models/sync_queue_item.dart';
import 'repositories/sync_queue_repository.dart';

abstract interface class SyncTransport {
  Future<void> push(SyncQueueItem item);
}

class SyncService {
  final SyncQueueRepository _queue;
  final SyncTransport _transport;

  SyncService({
    SyncQueueRepository? queue,
    required SyncTransport transport,
  })  : _queue = queue ?? SyncQueueRepository(),
        _transport = transport;

  Future<SyncResult> syncPending({int limit = 50}) async {
    final items = await _queue.pendingItems(limit: limit);
    var synced = 0;
    var failed = 0;

    for (final item in items) {
      try {
        jsonDecode(item.payload);
        await _transport.push(item);
        await _queue.markSynced(item.id);
        synced++;
      } catch (error) {
        await _queue.markFailed(item.id, error);
        failed++;
      }
    }

    return SyncResult(
      processed: items.length,
      synced: synced,
      failed: failed,
    );
  }
}

class SyncResult {
  final int processed;
  final int synced;
  final int failed;

  const SyncResult({
    required this.processed,
    required this.synced,
    required this.failed,
  });
}
