import '../database/database_helper.dart';

class SequenceIssue {
  final int documentId;
  final int sequenceNumber;
  final int folderNumber;
  final DateTime issueDate;

  const SequenceIssue({
    required this.documentId,
    required this.sequenceNumber,
    required this.folderNumber,
    required this.issueDate,
  });
}

class SequenceService {
  static const String sequenceDocumentType = 'sequence';

  static Future<SequenceIssue> issueSequenceDocument({
    required int studentId,
  }) async {
    final db = await DatabaseHelper.instance.database;

    return db.transaction((transaction) async {
      final now = DateTime.now();

      final folderNumber = now.year % 100;

      final result = await transaction.rawQuery(
        '''
        SELECT COALESCE(MAX(sequence_number), 0) AS max_number
        FROM issued_documents
        WHERE document_type = ?
          AND folder_number = ?
        ''',
        [
          sequenceDocumentType,
          folderNumber,
        ],
      );

      final maxNumber =
          (result.first['max_number'] as int?) ?? 0;

      final nextNumber = maxNumber + 1;

      final documentId = await transaction.insert(
        'issued_documents',
        {
          'student_id': studentId,
          'document_type': sequenceDocumentType,
          'issue_date': now.toIso8601String(),
          'file_path': null,
          'sequence_number': nextNumber,
          'folder_number': folderNumber,
        },
      );

      return SequenceIssue(
        documentId: documentId,
        sequenceNumber: nextNumber,
        folderNumber: folderNumber,
        issueDate: now,
      );
    });
  }

  static Future<SequenceIssue?> getLatestSequenceForStudent({
    required int studentId,
  }) async {
    final db = await DatabaseHelper.instance.database;

    final rows = await db.query(
      'issued_documents',
      where: '''
        student_id = ?
        AND document_type = ?
      ''',
      whereArgs: [
        studentId,
        sequenceDocumentType,
      ],
      orderBy: 'id DESC',
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    final row = rows.first;

    return SequenceIssue(
      documentId: row['id'] as int,
      sequenceNumber:
          row['sequence_number'] as int? ?? 0,
      folderNumber:
          row['folder_number'] as int? ??
              (DateTime.parse(
                row['issue_date'] as String,
              ).year %
                  100),
      issueDate:
          DateTime.parse(row['issue_date'] as String),
    );
  }
}