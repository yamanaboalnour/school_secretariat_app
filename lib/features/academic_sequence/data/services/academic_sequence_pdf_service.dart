import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/academic_sequence_model.dart';

class AcademicSequencePdfService {
  static const String _serialKey = 'academic_sequence_document_serial';

  static const String schoolName =
      'ثانوية الشيخ المربي عبد الكريم الرفاعي الشرعية للبنين';

  static const String volumeNumber = '26';

  static const String secretaryName = 'أنس أبو شامة';

  static const String principalName = 'معاذ نعمان';

  static Future<int> peekNextSerial() async {
    final prefs = await SharedPreferences.getInstance();

    return (prefs.getInt(_serialKey) ?? 0) + 1;
  }

  static Future<int> _takeSerial() async {
    final prefs = await SharedPreferences.getInstance();

    final serial = (prefs.getInt(_serialKey) ?? 0) + 1;

    await prefs.setInt(
      _serialKey,
      serial,
    );

    return serial;
  }

  static Future<void> printTranscript(
    AcademicStudent student,
  ) async {
    final serial = await _takeSerial();

    final bytes = await generateTranscript(
      student,
      serial: serial,
    );

    await Printing.layoutPdf(
      name: 'تسلسل دراسي - ${student.fullName} - $serial',
      format: PdfPageFormat.a4.landscape,
      onLayout: (_) async => bytes,
    );
  }

  static Future<Uint8List> generateTranscript(
    AcademicStudent student, {
    required int serial,
  }) async {
    final fontData = await rootBundle.load(
      'assets/fonts/TraditionalArabic.ttf',
    );

    final font = pw.Font.ttf(fontData);

    final logoData = await rootBundle.load(
      'assets/logo.png',
    );

    final logo = pw.MemoryImage(
      logoData.buffer.asUint8List(),
    );

    final document = pw.Document();

    final issueDate = _formatDate(
      DateTime.now(),
    );

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: pw.EdgeInsets.zero,
        build: (context) {
          return pw.Row(
            children: [
              pw.Expanded(
                child: _buildA5Document(
                  font: font,
                  logo: logo,
                  student: student,
                  serial: serial,
                  issueDate: issueDate,
                ),
              ),
              pw.Container(
                width: 0.8,
                margin: const pw.EdgeInsets.symmetric(
                  vertical: 5,
                ),
                color: PdfColors.black,
              ),
              pw.Expanded(
                child: _buildA5Document(
                  font: font,
                  logo: logo,
                  student: student,
                  serial: serial,
                  issueDate: issueDate,
                ),
              ),
            ],
          );
        },
      ),
    );

    return document.save();
  }

  static pw.Widget _buildA5Document({
    required pw.Font font,
    required pw.MemoryImage logo,
    required AcademicStudent student,
    required int serial,
    required String issueDate,
  }) {
    return pw.Container(
      margin: const pw.EdgeInsets.all(4),
      child: pw.Stack(
        children: [
          // إطار الورقة
          pw.Positioned.fill(
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: PdfColors.black,
                  width: 0.7,
                ),
              ),
            ),
          ),

          // العلامة المائية
          pw.Positioned.fill(
            child: pw.Center(
              child: pw.Opacity(
                opacity: 0.09,
                child: pw.Image(
                  logo,
                  width: 230,
                  height: 230,
                  fit: pw.BoxFit.contain,
                ),
              ),
            ),
          ),

          // محتوى الوثيقة
          pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(
              18,
              8,
              18,
              8,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _header(
                  font,
                  serial,
                ),
                pw.SizedBox(
                  height: 5,
                ),
                pw.Center(
                  child: pw.Text(
                    'وثيقة تسلسل دراسي',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(
                  height: 5,
                ),
                _studentInformation(
                  font,
                  student,
                ),
                pw.SizedBox(
                  height: 4,
                ),
                pw.Text(
                  'قضى الأعوام التالية في ثانويتنا:',
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(
                  height: 4,
                ),
                _recordsTable(
                  font,
                  student,
                ),
                pw.SizedBox(
                  height: 4,
                ),
                pw.Text(
                  'وتركت الثانوية بتاريخ: $issueDate والبيان أعطي هذه الوثيقة بناءً عليه.',
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Spacer(),
                _signatures(
                  font,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _header(
    pw.Font font,
    int serial,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // الترويسة في اليمين
        pw.Expanded(
          flex: 5,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'الجمهورية العربية السورية',
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  font: font,
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'وزارة الأوقاف',
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  font: font,
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'مديرية الأوقاف في محافظة دمشق',
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  font: font,
                  fontSize: 9.5,
                ),
              ),
              pw.Text(
                schoolName,
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  font: font,
                  fontSize: 10.5,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        pw.SizedBox(
          width: 12,
        ),

        // الأرقام في اليسار
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'الرقم المتسلسل: ${_arabicDigits(serial.toString())}',
              style: pw.TextStyle(
                font: font,
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              'رقم المجلد: ${_arabicDigits(volumeNumber)}',
              style: pw.TextStyle(
                font: font,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _studentInformation(
    pw.Font font,
    AcademicStudent student,
  ) {
    return pw.Column(
      children: [
        pw.Row(
          children: [
            pw.Expanded(
              child: _info(
                font,
                'إن الطالب',
                student.fullName,
              ),
            ),
            pw.Expanded(
              child: _info(
                font,
                'بن',
                student.fatherName,
              ),
            ),
          ],
        ),
        pw.SizedBox(
          height: 2,
        ),
        pw.Row(
          children: [
            pw.Expanded(
              child: _info(
                font,
                'المولود في',
                student.birthPlace,
              ),
            ),
            pw.Expanded(
              child: _info(
                font,
                'بتاريخ',
                student.birthDate,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _info(
    pw.Font font,
    String label,
    String value,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 2,
      ),
      child: pw.RichText(
        textAlign: pw.TextAlign.right,
        text: pw.TextSpan(
          style: pw.TextStyle(
            font: font,
            fontSize: 10,
          ),
          children: [
            pw.TextSpan(
              text: '$label: ',
              style: pw.TextStyle(
                font: font,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.TextSpan(
              text: value.isEmpty ? '................' : value,
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _recordsTable(
    pw.Font font,
    AcademicStudent student,
  ) {
    const int maxRows = 7;

    final rows = <pw.TableRow>[
      pw.TableRow(
        children: [
          _cell(
            font,
            'العام الدراسي',
            bold: true,
          ),
          _cell(
            font,
            'في الصف',
            bold: true,
          ),
          _cell(
            font,
            'النتيجة',
            bold: true,
          ),
        ],
      ),
    ];

    for (var i = 0; i < maxRows; i++) {
      if (i < student.records.length) {
        final record = student.records[i];

        rows.add(
          pw.TableRow(
            children: [
              _cell(
                font,
                _formatAcademicYear(
                  record.academicYear,
                ),
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
          ),
        );
      } else {
        rows.add(
          pw.TableRow(
            children: [
              _emptyCell(
                font,
                diagonal: true,
              ),
              _emptyCell(
                font,
                diagonal: true,
              ),
              _emptyCell(
                font,
                diagonal: true,
              ),
            ],
          ),
        );
      }
    }

    return pw.Table(
      border: pw.TableBorder.all(
        color: PdfColors.black,
        width: 0.55,
      ),
      columnWidths: const {
        0: pw.FlexColumnWidth(2.3),
        1: pw.FlexColumnWidth(1.35),
        2: pw.FlexColumnWidth(1.45),
      },
      children: rows,
    );
  }

  static pw.Widget _emptyCell(
    pw.Font font, {
    required bool diagonal,
  }) {
    return pw.Container(
      height: 27,
      child: diagonal
          ? pw.CustomPaint(
              size: const PdfPoint(
                100,
                27,
              ),
              painter: (canvas, size) {
                canvas
                  ..setLineWidth(
                    0.5,
                  )
                  ..moveTo(
                    0,
                    0,
                  )
                  ..lineTo(
                    size.x,
                    size.y,
                  )
                  ..stroke();
              },
            )
          : pw.SizedBox(
              height: 27,
            ),
    );
  }

  static pw.Widget _cell(
    pw.Font font,
    String text, {
    bool bold = false,
  }) {
    return pw.Container(
      height: 27,
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 3,
        vertical: 2,
      ),
      child: pw.Text(
        _arabicDigits(text),
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          font: font,
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _signatures(
    pw.Font font,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'أمين السر',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'الاسم: $secretaryName',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 10,
                ),
              ),
              pw.Text(
                'التوقيع:',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(
          width: 20,
        ),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'المدير',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'الاسم: $principalName',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 10,
                ),
              ),
              pw.Text(
                'التوقيع:',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 10,
                ),
              ),
              pw.Text(
                'والخاتم الرسمي:',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _formatAcademicYear(
    String value,
  ) {
    final parts = value.split('-');

    if (parts.length != 2) {
      return _arabicDigits(value);
    }

    return '${_arabicDigits(parts[1])} / ${_arabicDigits(parts[0])} م';
  }

  static String _formatDate(
    DateTime date,
  ) {
    return _arabicDigits(
      '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}',
    );
  }

  static String _arabicDigits(
    String value,
  ) {
    const latin = '0123456789';

    const arabic = '٠١٢٣٤٥٦٧٨٩';

    var result = value;

    for (var i = 0; i < latin.length; i++) {
      result = result.replaceAll(
        latin[i],
        arabic[i],
      );
    }

    return result;
  }
}
