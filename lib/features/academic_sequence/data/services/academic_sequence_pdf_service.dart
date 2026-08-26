import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/academic_sequence_model.dart';

class AcademicSequencePdfService {
  static Future<void> printTranscript(
    AcademicStudent student,
  ) async {
    final bytes = await generateTranscript(student);

    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: 'التسلسل الدراسي - ${student.fullName}',
    );
  }

  static Future<Uint8List> generateTranscript(
    AcademicStudent student,
  ) async {
    final fontData = await rootBundle.load(
      'assets/fonts/Amiri-Regular.ttf',
    );

    final font = pw.Font.ttf(fontData);

    final document = pw.Document();

    final theme = pw.ThemeData.withFont(
      base: font,
      bold: font,
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Center(
                    child: pw.Text(
                      'الجمهورية العربية السورية',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Center(
                    child: pw.Text(
                      'وزارة التربية والتعليم',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 18),
                  pw.Center(
                    child: pw.Text(
                      'التسلسل الدراسي',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 24),
                  _infoRow(
                    font,
                    'اسم الطالب',
                    student.fullName,
                  ),
                  _infoRow(
                    font,
                    'رقم الطالب',
                    student.studentNumber,
                  ),
                  _infoRow(
                    font,
                    'الصف الحالي',
                    student.currentGrade,
                  ),
                  _infoRow(
                    font,
                    'الشعبة',
                    student.section,
                  ),
                  pw.SizedBox(height: 20),
                  pw.Table(
                    border: pw.TableBorder.all(
                      color: PdfColors.grey600,
                    ),
                    columnWidths: const {
                      0: pw.FlexColumnWidth(2),
                      1: pw.FlexColumnWidth(1),
                      2: pw.FlexColumnWidth(2),
                    },
                    children: [
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.grey300,
                        ),
                        children: [
                          _cell(
                            font,
                            'العام الدراسي',
                            bold: true,
                          ),
                          _cell(
                            font,
                            'الصف',
                            bold: true,
                          ),
                          _cell(
                            font,
                            'النتيجة',
                            bold: true,
                          ),
                        ],
                      ),
                      ...student.records.map(
                        (record) {
                          return pw.TableRow(
                            children: [
                              _cell(
                                font,
                                record.academicYear,
                              ),
                              _cell(
                                font,
                                record.grade,
                              ),
                              _cell(
                                font,
                                record.status,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 40),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'توقيع أمين السر',
                        style: pw.TextStyle(font: font),
                      ),
                      pw.Text(
                        'توقيع المدير والختم',
                        style: pw.TextStyle(font: font),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return document.save();
  }

  static pw.Widget _infoRow(
    pw.Font font,
    String label,
    String value,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(
                font: font,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value.isEmpty ? '—' : value,
              style: pw.TextStyle(font: font),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _cell(
    pw.Font font,
    String text, {
    bool bold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(7),
      child: pw.Center(
        child: pw.Text(
          text.isEmpty ? '—' : text,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            font: font,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
