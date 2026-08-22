import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../../students/data/models/student_model.dart';
import '../../data/datasources/pdf_service.dart';

class DocumentPreviewPage extends StatelessWidget {
  final StudentModel student;

  const DocumentPreviewPage({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('طباعة وثيقة: ${student.firstName} ${student.lastName}'),
      ),
      body: PdfPreview(
        build: (format) => PdfService.generateSequenceDocument(student),
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
      ),
    );
  }
}