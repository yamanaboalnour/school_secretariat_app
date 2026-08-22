import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../students/data/models/student_model.dart';
import '../../../grades/data/models/grade_model.dart';
import '../../../settings/data/repositories/school_profile_repository.dart';
import '../services/document_verification_service.dart';

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
    final documentSerial = _documentSerial(student);
    final verificationToken = DocumentVerificationService.createToken(
      studentId: student.id ?? 0,
      studentName: '${student.firstName} ${student.lastName}',
      serial: documentSerial,
      documentType: 'sequence',
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

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.BarcodeWidget(
                      data: verificationToken,
                      barcode: pw.Barcode.qrCode(),
                      width: 55,
                      height: 55,
                    ),
                    pw.Text(
                      'الرقم التسلسلي: $documentSerial',
                      style: pw.TextStyle(font: font, fontSize: 9),
                    ),
                  ],
                ),

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

  /// توليد جلاء / كشف علامات مدرسي
  static Future<Uint8List> generateReportCard({
    required StudentModel student,
    required List<GradeModel> grades,
    String? schoolName,
  }) async {
    final pdf = pw.Document();
    final profile = await SchoolProfileRepository().getProfile();
    final resolvedSchoolName = _valueOrDefault(
      schoolName ?? profile.schoolName,
      'مدرسة الأمل الخاصة',
    );
    final font = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();
    final totalScore = grades.fold<double>(
      0,
      (sum, grade) => sum + grade.total,
    );
    final result = grades.isEmpty || grades.any((grade) => grade.total < 50)
        ? 'راسب'
        : 'ناجح';
    final documentSerial = _documentSerial(student);
    final verificationToken = DocumentVerificationService.createToken(
      studentId: student.id ?? 0,
      studentName: '${student.firstName} ${student.lastName}',
      serial: documentSerial,
      documentType: 'report_card',
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Text(
                  resolvedSchoolName,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(font: fontBold, fontSize: 15),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'كشف علامات الطالب (الجلاء المدرسي)',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(font: fontBold, fontSize: 18),
                ),
                pw.SizedBox(height: 15),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'اسم الطالب: ${student.firstName} ${student.lastName}',
                      style: pw.TextStyle(font: font, fontSize: 12),
                    ),
                    pw.Text(
                      'الصف: ${student.gradeLevel}',
                      style: pw.TextStyle(font: font, fontSize: 12),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.TableHelper.fromTextArray(
                  headers: ['المادة', 'الفصل الأول', 'الفصل الثاني', 'المجموع النهائي'],
                  data: grades
                      .map(
                        (grade) => [
                          grade.subjectName,
                          grade.firstTerm.toStringAsFixed(2),
                          grade.secondTerm.toStringAsFixed(2),
                          grade.total.toStringAsFixed(2),
                        ],
                      )
                      .toList(),
                  cellStyle: pw.TextStyle(font: font, fontSize: 11),
                  headerStyle: pw.TextStyle(font: fontBold, fontSize: 12),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  cellAlignment: pw.Alignment.center,
                ),
                pw.SizedBox(height: 20),
                pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'المجموع العام: ${totalScore.toStringAsFixed(2)}',
                        style: pw.TextStyle(font: fontBold, fontSize: 14),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        'النتيجة: $result',
                        style: pw.TextStyle(font: fontBold, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 18),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.BarcodeWidget(
                      data: verificationToken,
                      barcode: pw.Barcode.qrCode(),
                      width: 55,
                      height: 55,
                    ),
                    pw.Text(
                      'الرقم التسلسلي: $documentSerial',
                      style: pw.TextStyle(font: font, fontSize: 9),
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

  static String _valueOrDefault(String value, String fallback) {
    return value.trim().isEmpty ? fallback : value.trim();
  }

  static String _documentSerial(StudentModel student) {
    final timestamp = DateTime.now().toUtc().microsecondsSinceEpoch;
    return 'SCH-${student.id ?? 0}-$timestamp';
  }

}