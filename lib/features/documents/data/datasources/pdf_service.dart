import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../students/data/models/student_model.dart';

class PdfService {
  /// توليد وثيقة تسلسل دراسي
  static Future<Uint8List> generateSequenceDocument(StudentModel student) async {
    final pdf = pw.Document();

    // تحميل خط عربي للطباعة المتقنة
    final font = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              cross: pw.CrossAxisAlignment.start,
              children: [
                // الهيدر الرسمي
                pw.Row(
                  main: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      cross: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('الجمهورية العربية السورية', style: pw.TextStyle(font: font, fontSize: 12)),
                        pw.Text('وزارة التربية', style: pw.TextStyle(font: font, fontSize: 12)),
                        pw.Text('مديرية التربية', style: pw.TextStyle(font: font, fontSize: 12)),
                      ],
                    ),
                    pw.Text('أمانة السر المدرسية', style: pw.TextStyle(font: fontBold, fontSize: 16)),
                  ],
                ),
                pw.SizedBox(height: 30),

                // عنوان الوثيقة
                pw.Center(
                  child: pw.Text(
                    'وثيقة تسلسل دراسي',
                    style: pw.TextStyle(font: fontBold, fontSize: 20, decoration: pw.TextDecoration.underline),
                  ),
                ),
                pw.SizedBox(height: 40),

                // نص الوثيقة
                pw.Text(
                  'تشهد إدارة المدرسة بأن الطالب/ـة: ${student.firstName} ${student.lastName}',
                  style: pw.TextStyle(font: font, fontSize: 14),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'اسم الأب: ${student.fatherName}   |   اسم الأم: ${student.motherName}',
                  style: pw.TextStyle(font: font, fontSize: 14),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'الرقم الوطني / السجل: ${student.nationalId ?? "غير مدون"}',
                  style: pw.TextStyle(font: font, fontSize: 14),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'مسجل لدينا في الصف: ${student.gradeLevel} للعام الدراسي الحالي، وما زال مستمراً بالدراسة حتى تاريخه.',
                  style: pw.TextStyle(font: font, fontSize: 14),
                ),
                pw.SizedBox(height: 60),

                // التواقيع
                pw.Row(
                  main: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('أمبن السر: ....................', style: pw.TextStyle(font: font, fontSize: 12)),
                    pw.Text('مدير المدرسة: ....................', style: pw.TextStyle(font: fontBold, fontSize: 12)),
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