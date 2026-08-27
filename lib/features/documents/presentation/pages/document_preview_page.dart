import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../students/data/models/student_model.dart';
import '../../../../services/sequence_service.dart';
import '../../data/datasources/pdf_service.dart';

class DocumentPreviewPage extends StatefulWidget {
  final StudentModel student;

  const DocumentPreviewPage({
    super.key,
    required this.student,
  });

  @override
  State<DocumentPreviewPage> createState() =>
      _DocumentPreviewPageState();
}

class _DocumentPreviewPageState
    extends State<DocumentPreviewPage> {
  late final Future<Uint8List> _pdfFuture;

  @override
  void initState() {
    super.initState();

    _pdfFuture = _createPdf();
  }

  Future<Uint8List> _createPdf() async {
    final studentId = widget.student.id;

    if (studentId == null) {
      throw StateError(
        'لا يمكن طباعة وثيقة لطالب غير محفوظ في قاعدة البيانات.',
      );
    }

    final issue =
        await SequenceService.issueSequenceDocument(
      studentId: studentId,
    );

    return PdfService.generateSequenceDocument(
      student: widget.student,
      issue: issue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'طباعة التسلسل: '
          '${widget.student.firstName} '
          '${widget.student.lastName}',
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Uint8List>(
        future: _pdfFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'حدث خطأ أثناء إنشاء الوثيقة:\n\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final pdfBytes = snapshot.data;

          if (pdfBytes == null) {
            return const Center(
              child: Text(
                'تعذر إنشاء الوثيقة.',
              ),
            );
          }

          return PdfPreview(
            build: (_) async => pdfBytes,
            allowPrinting: true,
            allowSharing: true,
            canChangeOrientation: false,
            canChangePageFormat: false,
            canDebug: false,
          );
        },
      ),
    );
  }
}