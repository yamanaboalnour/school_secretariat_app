import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/student_model.dart';

class StudentCardPdfScreen extends StatelessWidget {
  final Student student;

  const StudentCardPdfScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1B3B2B);

    return Scaffold(
      appBar: AppBar(
        title: Text('بطاقة طالب - ${student.fullName}'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: PdfPreview(
        build: (format) => _generateCardPdf(format, student),
        allowPrinting: true,
        allowSharing: true,
        initialPageFormat: PdfPageFormat.a4,
      ),
    );
  }

  Future<Uint8List> _generateCardPdf(
      PdfPageFormat format, Student student) async {
    final pdf = pw.Document();

    final fontData = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();

    // نص الـ QR Code المضمن في البطاقة
    String qrData = '''
الجمهورية العربية السورية - وزارة الأوقاف
بطاقة طالب رسمية
- الاسم: ${student.fullName}
- الرقم العام: ${student.generalId}
- الصف: ${student.latestGrade}
- المدرسة: ثانوية الشيخ المربي عبد الكريم الرفاعي الشرعية للبنين
''';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Container(
              width: 250, // عرض البطاقة القياسي
              height: 150, // ارتفاع البطاقة القياسي
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.teal900, width: 2),
                borderRadius: pw.BorderRadius.circular(8),
                color: PdfColors.grey50,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // 1. ترويسة البطاقة
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    decoration: const pw.BoxDecoration(
                      color: PdfColor.fromInt(0xFF1B3B2B),
                      borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'ثانوية الشيخ المربي عبد الكريم الرفاعي الشرعية للبنين',
                          style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 7,
                              color: PdfColors.white),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.Text(
                          'بطاقة تعريف طالب',
                          style: pw.TextStyle(
                              font: fontData,
                              fontSize: 6,
                              color: PdfColors.yellow300),
                          textAlign: pw.TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 6),

                  // 2. تفاصيل البيانات والـ QR Code
                  pw.Expanded(
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        // بيانات الطالب
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                            children: [
                              pw.Text('الاسم: ${student.fullName}',
                                  style: pw.TextStyle(
                                      font: fontBold, fontSize: 8)),
                              pw.Text('الأب: ${student.fatherName}',
                                  style: pw.TextStyle(
                                      font: fontData, fontSize: 7)),
                              pw.Text('الأم: ${student.motherName}',
                                  style: pw.TextStyle(
                                      font: fontData, fontSize: 7)),
                              pw.Text('الرقم العام: ${student.generalId}',
                                  style: pw.TextStyle(
                                      font: fontBold,
                                      fontSize: 8,
                                      color: PdfColors.teal900)),
                              pw.Text('الصف الحالي: ${student.latestGrade}',
                                  style: pw.TextStyle(
                                      font: fontData, fontSize: 7)),
                            ],
                          ),
                        ),

                        // رمز الـ QR Code
                        pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.BarcodeWidget(
                              data: qrData,
                              barcode: pw.Barcode.qrCode(),
                              width: 45,
                              height: 45,
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text('الختم الرقمي',
                                style: pw.TextStyle(
                                    font: fontData,
                                    fontSize: 5,
                                    color: PdfColors.grey700)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 3. التذييل للتوقيع
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('تاريخ الولادة: ${student.birthDate}',
                          style: pw.TextStyle(
                              font: fontData,
                              fontSize: 6,
                              color: PdfColors.grey800)),
                      pw.Text('توقيع مدير الثانوية: .........',
                          style: pw.TextStyle(font: fontData, fontSize: 6)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}
