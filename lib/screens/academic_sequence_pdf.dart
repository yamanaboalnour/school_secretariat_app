import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/student_model.dart';
import '../services/sequence_service.dart';

class AcademicSequencePdfScreen extends StatefulWidget {
  final Student student;

  const AcademicSequencePdfScreen({Key? key, required this.student}) : super(key: key);

  @override
  State<AcademicSequencePdfScreen> createState() => _AcademicSequencePdfScreenState();
}

class _AcademicSequencePdfScreenState extends State<AcademicSequencePdfScreen> {
  int? _issuedSequenceNumber;

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1B3B2B);

    return Scaffold(
      appBar: AppBar(
        title: Text('وثيقة تسلسل دراسي - ${widget.student.fullName}'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: PdfPreview(
        build: (format) => _generatePdf(format, widget.student),
        allowPrinting: true,
        allowSharing: true,
        initialPageFormat: PdfPageFormat.a4,
        onPrinted: (context) async {
          int newSeq = await SequenceService.issueAndSaveSequenceNumber();
          setState(() {
            _issuedSequenceNumber = newSeq;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم تسجيل وطباعة الوثيقة بالرقم المتسلسل الرسمي: $newSeq')),
          );
        },
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format, Student student) async {
    final pdf = pw.Document();

    int currentSeq = _issuedSequenceNumber ?? await SequenceService.getNextSequenceNumber();
    String issueDate = '${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day}';

    // نص الـ QR Code للتحقق من مصداقية الوثيقة
    String qrData = '''
ثانوية الشيخ المربي عبد الكريم الرفاعي الشرعية للبنين
رمز التحقق من صحة الوثيقة:
- الرقم التسلسلي: $currentSeq
- الرقم العام: ${student.generalId}
- اسم الطالب: ${student.fullName}
- تاريخ الإصدار: $issueDate
''';

    final fontData = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(25),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // 1. الترويسة الرسمية
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('الرقم المتسلسل الرسمي: $currentSeq', style: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColors.teal900)),
                        pw.Text('الرقم العام للطالب: ${student.generalId}', style: pw.TextStyle(font: fontData, fontSize: 10)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text('الجمهورية العربية السورية', style: pw.TextStyle(font: fontBold, fontSize: 11)),
                        pw.Text('وزارة الأوقاف', style: pw.TextStyle(font: fontBold, fontSize: 11)),
                        pw.Text('مديرية الأوقاف في محافظة دمشق', style: pw.TextStyle(font: fontData, fontSize: 10)),
                        pw.Text('ثانوية الشيخ المربي عبد الكريم الرفاعي الشرعية للبنين', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),

                // 2. عنوان الوثيقة
                pw.Center(
                  child: pw.Text(
                    'وثيقة تسلسل دراسي',
                    style: pw.TextStyle(font: fontBold, fontSize: 20, decoration: pw.TextDecoration.underline),
                  ),
                ),
                pw.SizedBox(height: 20),

                // 3. بيانات الطالب
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('إن الطالب: ${student.fullName}', style: pw.TextStyle(font: fontBold, fontSize: 11)),
                    pw.Text('بن السيد: ${student.fatherName}', style: pw.TextStyle(font: fontData, fontSize: 11)),
                    pw.Text('الأم: ${student.motherName}', style: pw.TextStyle(font: fontData, fontSize: 11)),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('المولود في: ${student.birthPlace}', style: pw.TextStyle(font: fontData, fontSize: 11)),
                    pw.Text('بتاريخ: ${student.birthDate}', style: pw.TextStyle(font: fontData, fontSize: 11)),
                  ],
                ),
                pw.SizedBox(height: 15),
                pw.Text('قضى الأعوام الدراسية التالية في ثانويتنا:', style: pw.TextStyle(font: fontBold, fontSize: 11)),
                pw.SizedBox(height: 10),

                // 4. جدول التسلسل الدراسي
                pw.Table(
                  border: pw.TableBorder.all(width: 1, color: PdfColors.grey600),
                  columnWidths: const {
                    0: pw.FlexColumnWidth(2),
                    1: pw.FlexColumnWidth(1.5),
                    2: pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.teal50),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Center(child: pw.Text('العام الدراسي', style: pw.TextStyle(font: fontBold, fontSize: 10))),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Center(child: pw.Text('في الصف', style: pw.TextStyle(font: fontBold, fontSize: 10))),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Center(child: pw.Text('النتيجة', style: pw.TextStyle(font: fontBold, fontSize: 10))),
                        ),
                      ],
                    ),
                    ...student.academicHistory.entries.map((entry) {
                      final year = entry.key;
                      final resultParts = entry.value.split('/');
                      final result = resultParts[0].trim();
                      final grade = resultParts.length > 1 ? _formatGrade(resultParts[1].trim()) : '-';

                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Center(child: pw.Text(year, style: pw.TextStyle(font: fontData, fontSize: 10))),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Center(child: pw.Text(grade, style: pw.TextStyle(font: fontData, fontSize: 10))),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Center(child: pw.Text(result, style: pw.TextStyle(font: fontBold, fontSize: 10))),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
                pw.SizedBox(height: 20),

                // 5. التوقيع الختامي ومساحة الـ QR Code
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('وترك الثانوية بتاريخ:  /  /   م', style: pw.TextStyle(font: fontData, fontSize: 10)),
                    pw.Text('اعُطيت هذه الوثيقة بتاريخ: $issueDate', style: pw.TextStyle(font: fontData, fontSize: 10)),
                  ],
                ),
                pw.Spacer(),

                // 6. تذييل الوثيقة والتحقق من الموثوقية بـ QR Code
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    // الـ QR Code
                    pw.Column(
                      children: [
                        pw.BarcodeWidget(
                          data: qrData,
                          barcode: pw.Barcode.qrCode(),
                          width: 65,
                          height: 65,
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text('رمز التحقق الإلكتروني', style: pw.TextStyle(font: fontData, fontSize: 7, color: PdfColors.grey700)),
                      ],
                    ),

                    // التواقيع الرسمية
                    pw.Row(
                      children: [
                        pw.Column(
                          children: [
                            pw.Text('أمين السر', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                            pw.SizedBox(height: 20),
                            pw.Text('التوقيع: ....................', style: pw.TextStyle(font: fontData, fontSize: 9)),
                          ],
                        ),
                        pw.SizedBox(width: 40),
                        pw.Column(
                          children: [
                            pw.Text('مدير الثانوية', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                            pw.SizedBox(height: 20),
                            pw.Text('التوقيع والخاتم: ....................', style: pw.TextStyle(font: fontData, fontSize: 9)),
                          ],
                        ),
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

  static String _formatGrade(String grade) {
    switch (grade) {
      case '7': return 'السابع';
      case '8': return 'الثامن';
      case '9': return 'التاسع';
      case '10': return 'العاشر';
      case '11': return 'الحادي عشر';
      case '12': return 'الثاني عشر';
      default: return grade;
    }
  }
}