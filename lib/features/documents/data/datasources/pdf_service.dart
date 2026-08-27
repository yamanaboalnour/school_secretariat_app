import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../students/data/models/student_model.dart';
import '../../../settings/data/repositories/school_profile_repository.dart';

import '../../../../services/sequence_service.dart';

class PdfService {
  static Future<Uint8List> generateSequenceDocument({
    required StudentModel student,
    required SequenceIssue issue,
    String? schoolName,
    String? governorate,
    String? directorName,
    String? secretaryName,
  }) async {
    final pdf = pw.Document();

    final profile =
        await SchoolProfileRepository().getProfile();

    final resolvedSchoolName =
        _valueOrFallback(
      schoolName ?? profile.schoolName,
      'الثانوية',
    );

    final resolvedGovernorate =
        _valueOrFallback(
      governorate ?? profile.governorate,
      '',
    );

    final resolvedDirectorName =
        _valueOrFallback(
      directorName ?? profile.directorName,
      '',
    );

    final resolvedSecretaryName =
        _valueOrFallback(
      secretaryName ?? profile.secretaryName,
      '',
    );

    final fontData =
        await rootBundle.load(
      'assets/fonts/TraditionalArabic.ttf',
    );

    final traditionalArabic =
        pw.Font.ttf(fontData);

    final leavingDate =
        _formatDate(issue.issueDate);

    final studentFullName =
        '${student.firstName} ${student.lastName}'
            .trim();

    final birthPlace =
        _displayValue(student.birthPlace);

    final birthDate =
        _displayValue(student.birthDate);

    final nationalId =
        _displayValue(student.nationalId);

    final folderNumber =
        issue.folderNumber.toString();

    final sequenceNumber =
        issue.sequenceNumber.toString();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(
          42,
          32,
          42,
          36,
        ),
        textDirection: pw.TextDirection.rtl,
        build: (context) {
          return pw.Column(
            crossAxisAlignment:
                pw.CrossAxisAlignment.stretch,
            children: [
              _buildHeader(
                font: traditionalArabic,
                schoolName: resolvedSchoolName,
                governorate: resolvedGovernorate,
                sequenceNumber: sequenceNumber,
                folderNumber: folderNumber,
              ),

              pw.SizedBox(height: 18),

              pw.Center(
                child: pw.Text(
                  'بيان تسلسل دراسي',
                  style: pw.TextStyle(
                    font: traditionalArabic,
                    fontSize: 22,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),

              pw.SizedBox(height: 18),

              pw.Container(
                padding:
                    const pw.EdgeInsets.all(8),
                child: pw.Column(
                  crossAxisAlignment:
                      pw.CrossAxisAlignment.stretch,
                  children: [
                    _buildInfoRow(
                      font: traditionalArabic,
                      label: 'اسم الطالب',
                      value: studentFullName,
                    ),
                    _buildInfoRow(
                      font: traditionalArabic,
                      label: 'اسم الأب',
                      value: student.fatherName,
                    ),
                    _buildInfoRow(
                      font: traditionalArabic,
                      label: 'اسم الأم',
                      value: student.motherName,
                    ),
                    _buildInfoRow(
                      font: traditionalArabic,
                      label: 'مكان الولادة',
                      value: birthPlace,
                    ),
                    _buildInfoRow(
                      font: traditionalArabic,
                      label: 'تاريخ الولادة',
                      value: birthDate,
                    ),
                    _buildInfoRow(
                      font: traditionalArabic,
                      label: 'الصف الدراسي',
                      value: student.gradeLevel,
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 22),

              _buildSequenceSection(
                font: traditionalArabic,
                student: student,
              ),

              pw.Spacer(),

              pw.Divider(
                thickness: 0.8,
              ),

              pw.SizedBox(height: 8),

              pw.Text(
                'الرقم الوطني / السجل: $nationalId',
                style: pw.TextStyle(
                  font: traditionalArabic,
                  fontSize: 12,
                ),
              ),

              pw.SizedBox(height: 5),

              pw.Text(
                'تاريخ ترك المدرسة: $leavingDate',
                style: pw.TextStyle(
                  font: traditionalArabic,
                  fontSize: 15,
                ),
                textAlign: pw.TextAlign.right,
              ),

              pw.SizedBox(height: 24),

              pw.Row(
                crossAxisAlignment:
                    pw.CrossAxisAlignment.start,
                mainAxisAlignment:
                    pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment:
                          pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'أمين السر',
                          style: pw.TextStyle(
                            font: traditionalArabic,
                            fontSize: 16,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          resolvedSecretaryName,
                          style: pw.TextStyle(
                            font: traditionalArabic,
                            fontSize: 15,
                          ),
                          textAlign:
                              pw.TextAlign.center,
                        ),
                        pw.SizedBox(height: 18),
                        pw.Text(
                          'التوقيع: ........................',
                          style: pw.TextStyle(
                            font: traditionalArabic,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(width: 25),

                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment:
                          pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'مدير المدرسة',
                          style: pw.TextStyle(
                            font: traditionalArabic,
                            fontSize: 16,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          resolvedDirectorName,
                          style: pw.TextStyle(
                            font: traditionalArabic,
                            fontSize: 15,
                          ),
                          textAlign:
                              pw.TextAlign.center,
                        ),
                        pw.SizedBox(height: 18),
                        pw.Text(
                          'التوقيع والختم',
                          style: pw.TextStyle(
                            font: traditionalArabic,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 12),

              pw.Align(
                alignment:
                    pw.Alignment.centerLeft,
                child: pw.Text(
                  'رقم الطالب: ${student.id ?? ''}',
                  style: pw.TextStyle(
                    font: traditionalArabic,
                    fontSize: 7,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader({
    required pw.Font font,
    required String schoolName,
    required String governorate,
    required String sequenceNumber,
    required String folderNumber,
  }) {
    return pw.Row(
      mainAxisAlignment:
          pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment:
          pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment:
              pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'الرقم: $sequenceNumber',
              style: pw.TextStyle(
                font: font,
                fontSize: 15,
              ),
            ),
            pw.Text(
              'المجلد: $folderNumber',
              style: pw.TextStyle(
                font: font,
                fontSize: 15,
              ),
            ),
          ],
        ),

        pw.Column(
          crossAxisAlignment:
              pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'الجمهورية العربية السورية',
              style: pw.TextStyle(
                font: font,
                fontSize: 16,
              ),
              textAlign: pw.TextAlign.right,
            ),
            pw.Text(
              'وزارة التربية',
              style: pw.TextStyle(
                font: font,
                fontSize: 16,
              ),
              textAlign: pw.TextAlign.right,
            ),
            if (governorate.isNotEmpty)
              pw.Text(
                'مديرية تربية $governorate',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 15,
                ),
                textAlign: pw.TextAlign.right,
              ),
            pw.Text(
              schoolName,
              style: pw.TextStyle(
                font: font,
                fontSize: 17,
              ),
              textAlign: pw.TextAlign.right,
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildInfoRow({
    required pw.Font font,
    required String label,
    required String value,
  }) {
    return pw.Padding(
      padding:
          const pw.EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: pw.Row(
        crossAxisAlignment:
            pw.CrossAxisAlignment.end,
        children: [
          pw.Text(
            '$label:',
            style: pw.TextStyle(
              font: font,
              fontSize: 16,
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                font: font,
                fontSize: 16,
              ),
              textAlign:
                  pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSequenceSection({
    required pw.Font font,
    required StudentModel student,
  }) {
    return pw.Column(
      crossAxisAlignment:
          pw.CrossAxisAlignment.stretch,
      children: [
        pw.Center(
          child: pw.Text(
            'التسلسل الدراسي',
            style: pw.TextStyle(
              font: font,
              fontSize: 18,
            ),
          ),
        ),

        pw.SizedBox(height: 10),

        pw.Table(
          border: pw.TableBorder.all(
            width: 0.7,
          ),
          columnWidths: const {
            0: pw.FixedColumnWidth(65),
            1: pw.FlexColumnWidth(2.5),
            2: pw.FlexColumnWidth(2),
            3: pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              children: [
                _tableCell(
                  font,
                  'الرقم',
                ),
                _tableCell(
                  font,
                  'الصف',
                ),
                _tableCell(
                  font,
                  'العام الدراسي',
                ),
                _tableCell(
                  font,
                  'الحالة',
                ),
              ],
            ),
            pw.TableRow(
              children: [
                _tableCell(
                  font,
                  '1',
                ),
                _tableCell(
                  font,
                  student.gradeLevel,
                ),
                _tableCell(
                  font,
                  '',
                ),
                _tableCell(
                  font,
                  'مستجد',
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _tableCell(
    pw.Font font,
    String value,
  ) {
    return pw.Container(
      padding:
          const pw.EdgeInsets.all(6),
      alignment:
          pw.Alignment.center,
      child: pw.Text(
        value,
        style: pw.TextStyle(
          font: font,
          fontSize: 14,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static String _displayValue(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'غير مدون';
    }

    return value.trim();
  }

  static String _valueOrFallback(
    String value,
    String fallback,
  ) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return fallback;
    }

    return trimmed;
  }

  static String _formatDate(
    DateTime date,
  ) {
    final day = date.day
        .toString()
        .padLeft(2, '0');

    final month = date.month
        .toString()
        .padLeft(2, '0');

    final year = date.year.toString();

    return '$day/$month/$year';
  }
}