import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../students/data/models/student_model.dart';
import '../../../settings/data/repositories/school_profile_repository.dart';

class PdfService {
  /// توليد وثيقة تسلسل دراسي
  static Future<Uint8List> generateSequenceDocument(
    StudentModel student, {
    String? schoolName,
    String? governorate,
    String? directorName,
    String? secretaryName,
  }) async {
    final pdf = pw.Document();
    final profile = await SchoolProfileRepository().getProfile();
    final resolvedSchoolName = _valueOrDefault(
      schoolName ?? profile.schoolName,
      'مدرسة الأمل الخاصة',
    );
    final resolvedGovernorate = _valueOrDefault(
      governorate ?? profile.governorate,
      'دمشق',
    );
    final resolvedDirectorName = _valueOrDefault(
      directorName ?? profile.directorName,
      'أحمد العلي',
    );
    final resolvedSecretaryName = _valueOrDefault(
      secretaryName ?? profile.secretaryName,
      'محمد خليل',
    );

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
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // الهيدر الرسمي
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('الجمهورية العربية السورية', style: pw.TextStyle(font: font, fontSize: 12)),
                        pw.Text('وزارة التربية', style: pw.TextStyle(font: font, fontSize: 12)),
                        pw.Text('مديرية تربية $resolvedGovernorate', style: pw.TextStyle(font: font, fontSize: 12)),
                        pw.Text(resolvedSchoolName, style: pw.TextStyle(font: fontBold, fontSize: 13)),
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
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('أمين السر: $resolvedSecretaryName', style: pw.TextStyle(font: font, fontSize: 12)),
                    pw.Text('مدير المدرسة: $resolvedDirectorName', style: pw.TextStyle(font: fontBold, fontSize: 12)),
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

  static String _valueOrDefault(String value, String fallback) {
    return value.trim().isEmpty ? fallback : value.trim();
  }
}