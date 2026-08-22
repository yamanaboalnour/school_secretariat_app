import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/student_model.dart';

class AcademicSequencePdfScreen extends StatelessWidget {
  final Student student;

  const AcademicSequencePdfScreen({Key? key, required this.student})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1B3B2B);

    return Scaffold(
      appBar: AppBar(
        title: Text('تسلسل دراسي: ${student.fullName}'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: PdfPreview(
        build: (format) => _generatePdf(format, student),
        canChangeOrientation: false,
        canChangePageFormat: false,
      ),
    );
  }

  Future<List<int>> _generatePdf(
      PdfPageFormat format, Student student) async {
    final pdf = pw.Document();

    // نص الـ QR المودع لمنع التزوير والتحقق من أمانة السر
    final qrData =
        "VERIFIED_SEC_DOC|ID:${student.generalId}|NAME:${student.fullName}|STATUS:${student.latestStatus}";

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // ترويسة الوثيقة
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('الجمهورية العربية السورية',
                            style: pw.TextStyle(
                                fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.Text('وزارة التربية',
                            style: const pw.TextStyle(fontSize: 12)),
                        pw.Text('مديرية التربية - أمانة سر الثانوية',
                            style: const pw.TextStyle(fontSize: 12)),
                      ],
                    ),
                    pw.Text(
                      'وثيقة تسلسل دراسي',
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                pw.Divider(thickness: 1.5),
                pw.SizedBox(height: 20),

                // بيانات الطالب
                pw.Text('يشهد مدير الثانوية بأن الطالب/ة:',
                    style: const pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 10),
                pw.Bullet(
                    text:
                        'الاسم الكامل: ${student.fullName} (الأب: ${student.fatherName} - الأم: ${student.motherName})'),
                pw.Bullet(text: 'الرقم العام للسجل: ${student.generalId}'),
                pw.Bullet(
                    text:
                        'مكان وتاريخ الولادة: ${student.birthPlace} - ${student.birthDate}'),
                pw.Bullet(text: 'الصف الحالي: ${student.latestGrade}'),
                pw.Bullet(text: 'الوضع الدراسي: ${student.latestStatus}'),
                pw.SizedBox(height: 30),

                pw.Text(
                  'أُعطيت هذه الوثيقة بناءً على طلبه/ا لاستخدامها في الأغراض الرسمية.',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.Spacer(),

                // التوقيع ورمز الـ QR Code للتثبت
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    // الـ QR Code
                    pw.Container(
                      height: 80,
                      width: 80,
                      child: pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: qrData,
                      ),
                    ),
                    // الخاتم والتوقيع
                    pw.Column(
                      children: [
                        pw.Text('أمين السر',
                            style: pw.TextStyle(
                                fontSize: 12, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 40),
                        pw.Text('مدير المدرسة',
                            style: pw.TextStyle(
                                fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}