import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/student_model.dart';

class AcademicSequencePdfScreen extends StatelessWidget {
  final Student student;

  const AcademicSequencePdfScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تسلسل دراسي: ${student.fullName}'),
      ),
      body: PdfPreview(
        build: (format) => _generatePdf(format, student),
        allowPrinting: true,
        allowSharing: true,
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format, Student student) async {
    final pdf = pw.Document();

    // تحميل خط عربي لدعم النص العربي بشكل صحيح
    final fontData = await rootBundle.load('assets/fonts/Amiri-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'الجمهورية العربية السورية',
                    style: pw.TextStyle(font: ttf, fontSize: 16),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    'وزارة التربية',
                    style: pw.TextStyle(font: ttf, fontSize: 14),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Text(
                    'وثيقة تسلسل دراسي',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 30),
                pw.Text(
                  'الاسم الكامل: ${student.fullName}',
                  style: pw.TextStyle(font: ttf, fontSize: 14),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'اسم الأب: ${student.fatherName}',
                  style: pw.TextStyle(font: ttf, fontSize: 14),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'اسم الأم: ${student.motherName}',
                  style: pw.TextStyle(font: ttf, fontSize: 14),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'مكان وتاريخ الولادة: ${student.birthPlace} - ${student.birthDate}',
                  style: pw.TextStyle(font: ttf, fontSize: 14),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'الصف الحالي/الأخير: ${student.latestGrade}',
                  style: pw.TextStyle(font: ttf, fontSize: 14),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'الوضع الدراسي: ${student.latestStatus}',
                  style: pw.TextStyle(font: ttf, fontSize: 14),
                ),
                pw.Spacer(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('منظم الوثيقة',
                        style: pw.TextStyle(font: ttf, fontSize: 12)),
                    pw.Text('مدير المدرسة',
                        style: pw.TextStyle(font: ttf, fontSize: 12)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    final pdfBytes = await pdf.save();
    return Uint8List.fromList(pdfBytes);
  }
}
