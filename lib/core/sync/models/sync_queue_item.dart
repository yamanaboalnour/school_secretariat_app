class SyncQueueItem {
  final int id;
  final String entityType;
  final String entityId;
  final String operation;
  final String payload;
  final String status;
  final int attempts;
  final String? lastError;
  final DateTime createdAt;

  const SyncQueueItem({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.status,
    required this.attempts,
    required this.lastError,
    required this.createdAt,
  });

  factory SyncQueueItem.fromMap(Map<String, dynamic> map) {
    return SyncQueueItem(
      id: map['id'] as int,
      entityType: map['entity_type'] as String,
      entityId: map['entity_id'] as String,
      operation: map['operation'] as String,
      payload: map['payload'] as String,
      status: map['status'] as String,
      attempts: map['attempts'] as int,
      lastError: map['last_error'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
