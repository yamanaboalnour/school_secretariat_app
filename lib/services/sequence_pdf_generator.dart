import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/student_model.dart';
import '../utils/arabic_formatters.dart';

class SequencePdfGenerator {
  static Future<Uint8List> generateSequenceDocument(
    Student student, {
    String serialNumber = '83',
    String secretaryName = 'أنس أبو شامة',
    String managerName = 'معاذ نعمان',
  }) async {
    final pdf = pw.Document();

    // تحميل الخطوط الرسمية Traditional Arabic
    final fontData = await rootBundle.load('assets/fonts/traditional_arabic.ttf');
    final fontBoldData = await rootBundle.load('assets/fonts/traditional_arabic_bold.ttf');
    
    final ttfFont = pw.Font.ttf(fontData);
    final ttfBold = pw.Font.ttf(fontBoldData);

    final String volumeNumber = ArabicFormatters.getVolumeNumber(); // "26"
    final String currentDate = ArabicFormatters.getCurrentFormattedDate();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Row(
              children: [
                // الوثيقة الأولى (اليمنى)
                pw.Expanded(
                  child: _buildSingleDocument(
                    student: student,
                    serialNumber: serialNumber,
                    volumeNumber: volumeNumber,
                    currentDate: currentDate,
                    secretaryName: secretaryName,
                    managerName: managerName,
                    font: ttfFont,
                    fontBold: ttfBold,
                  ),
                ),
                // خط فاصل منقط للقص المنتصف
                pw.Container(
                  width: 1,
                  margin: const pw.EdgeInsets.symmetric(horizontal: 8),
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      30,
                      (_) => pw.Container(
                        width: 1,
                        height: 4,
                        color: PdfColors.grey500,
                      ),
                    ),
                  ),
                ),
                // الوثيقة الثانية (اليسرى - مطابقة)
                pw.Expanded(
                  child: _buildSingleDocument(
                    student: student,
                    serialNumber: serialNumber,
                    volumeNumber: volumeNumber,
                    currentDate: currentDate,
                    secretaryName: secretaryName,
                    managerName: managerName,
                    font: ttfFont,
                    fontBold: ttfBold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildSingleDocument({
    required Student student,
    required String serialNumber,
    required String volumeNumber,
    required String currentDate,
    required String secretaryName,
    required String managerName,
    required pw.Font font,
    required pw.Font fontBold,
  }) {
    const double baseFontSize = 12.0;

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1.2),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // 1. الترويسة العليا والرمز الجانبي
          pw.Stack(
            children: [
              // رقم الطالب المصغر في الزاوية الجانبية العليا (متطلب رقم 7)
              pw.Positioned(
                top: 0,
                left: 0,
                child: pw.Text(
                  student.id,
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 7,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // أقصى أعلى اليمين: الترويسة الرسمية (متطلب رقم 6)
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('الجمهورية العربية السورية',
                          style: pw.TextStyle(font: fontBold, fontSize: 11)),
                      pw.Text('وزارة الأوقاف',
                          style: pw.TextStyle(font: fontBold, fontSize: 11)),
                      pw.Text('مديرية الأوقاف في محافظة دمشق',
                          style: pw.TextStyle(font: font, fontSize: 10)),
                      pw.Text('ثانوية الشيخ المربي عبد الكريم الرفاعي الشرعية للبنين',
                          style: pw.TextStyle(font: fontBold, fontSize: 10)),
                    ],
                  ),
                  // أقصى اليسار: الرقم المتسلسل ورقم المجلد (متطلب رقم 2 و 6)
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        children: [
                          pw.Text('الرقم المتسلسل: ',
                              style: pw.TextStyle(font: fontBold, fontSize: 11)),
                          pw.Text(serialNumber,
                              style: pw.TextStyle(font: font, fontSize: 11)),
                        ],
                      ),
                      pw.SizedBox(height: 3),
                      pw.Row(
                        children: [
                          pw.Text('رقم المجلد: ',
                              style: pw.TextStyle(font: fontBold, fontSize: 11)),
                          pw.Text(volumeNumber,
                              style: pw.TextStyle(font: fontBold, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 10),

          // 2. عنوان الوثيقة
          pw.Center(
            child: pw.Text(
              'وثيقة تسلسل دراسي',
              style: pw.TextStyle(font: fontBold, fontSize: 18),
            ),
          ),

          pw.SizedBox(height: 12),

          // 3. بيانات الطالب المتكاملة (متطلب رقم 1)
          pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                            text: 'إن الطالب: ',
                            style: pw.TextStyle(font: fontBold, fontSize: baseFontSize)),
                        pw.TextSpan(
                            text: student.fullName,
                            style: pw.TextStyle(font: fontBold, fontSize: baseFontSize)),
                      ],
                    ),
                  ),
                  pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                            text: 'بن السيد: ',
                            style: pw.TextStyle(font: fontBold, fontSize: baseFontSize)),
                        pw.TextSpan(
                            text: student.fatherName,
                            style: pw.TextStyle(font: font, fontSize: baseFontSize)),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                            text: 'المولود في: ',
                            style: pw.TextStyle(font: fontBold, fontSize: baseFontSize)),
                        pw.TextSpan(
                            text: student.birthPlace,
                            style: pw.TextStyle(font: font, fontSize: baseFontSize)),
                      ],
                    ),
                  ),
                  pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                            text: 'بتاريخ: ',
                            style: pw.TextStyle(font: fontBold, fontSize: baseFontSize)),
                        pw.TextSpan(
                            text: student.birthDate,
                            style: pw.TextStyle(font: font, fontSize: baseFontSize)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 10),
          pw.Text('قضى الأعوام التالية في ثانويتنا:',
              style: pw.TextStyle(font: fontBold, fontSize: 11)),
          pw.SizedBox(height: 6),

          // 4. جدول التسلسل الدراسي والشطب القطري (متطلب رقم 4 و 5)
          _buildAcademicTable(student.records, font, fontBold),

          pw.SizedBox(height: 10),

          // 5. عبارة الترك وتاريخ اليوم الحالي (متطلب رقم 8)
          pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                    text: 'وترك الثانوية بتاريخ ',
                    style: pw.TextStyle(font: fontBold, fontSize: 11)),
                pw.TextSpan(
                    text: '$currentDate  ',
                    style: pw.TextStyle(font: fontBold, fontSize: 11)),
                pw.TextSpan(
                    text: 'ولبيان أعطي هذه الوثيقة',
                    style: pw.TextStyle(font: fontBold, fontSize: 11)),
              ],
            ),
          ),

          pw.Spacer(),

          // 6. التواضيع والختم الرسمي (متطلب رقم 9)
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // أمين السر (توقيع فقط)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('أمين السر:',
                      style: pw.TextStyle(font: fontBold, fontSize: 11)),
                  pw.SizedBox(height: 4),
                  pw.Text('الاسم: $secretaryName',
                      style: pw.TextStyle(font: fontBold, fontSize: 11)),
                  pw.SizedBox(height: 4),
                  pw.Text('التوقيع:',
                      style: pw.TextStyle(font: fontBold, fontSize: 11)),
                ],
              ),
              // المدير (توقيع + خاتم رسمي)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('المدير:',
                      style: pw.TextStyle(font: fontBold, fontSize: 11)),
                  pw.SizedBox(height: 4),
                  pw.Text('الاسم: $managerName',
                      style: pw.TextStyle(font: fontBold, fontSize: 11)),
                  pw.SizedBox(height: 4),
                  pw.Text('التوقيع:',
                      style: pw.TextStyle(font: fontBold, fontSize: 11)),
                  pw.SizedBox(height: 4),
                  pw.Text('والخاتم الرسمي:',
                      style: pw.TextStyle(font: fontBold, fontSize: 11)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 10),
        ],
      ),
    );
  }

  /// بناء الجدول مع الشطب القطري للأسطر الفارغة
  static pw.Widget _buildAcademicTable(
    List<AcademicRecord> records,
    pw.Font font,
    pw.Font fontBold,
  ) {
    const int totalRows = 7; // الإجمالي المعتمد في ورقة التسلسل
    final List<pw.TableRow> tableRows = [];

    // ترويسة الجدول
    tableRows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(5),
            child: pw.Center(
                child: pw.Text('العام الدراسي',
                    style: pw.TextStyle(font: fontBold, fontSize: 11))),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(5),
            child: pw.Center(
                child: pw.Text('في الصف',
                    style: pw.TextStyle(font: fontBold, fontSize: 11))),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(5),
            child: pw.Center(
                child: pw.Text('النتيجة',
                    style: pw.TextStyle(font: fontBold, fontSize: 11))),
          ),
        ],
      ),
    );

    // إضافة أسطر البيانات الفعلية
    for (int i = 0; i < records.length && i < totalRows; i++) {
      final rec = records[i];
      final gradeName = ArabicFormatters.getGradeName(rec.grade);

      tableRows.add(
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 4),
              child: pw.Center(
                  child: pw.Text(rec.academicYear,
                      style: pw.TextStyle(font: font, fontSize: 11))),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 4),
              child: pw.Center(
                  child: pw.Text('في الصف  $gradeName',
                      style: pw.TextStyle(font: fontBold, fontSize: 11))),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 4),
              child: pw.Center(
                  child: pw.Text('${rec.status} / ${i + 7}',
                      style: pw.TextStyle(font: fontBold, fontSize: 11))),
            ),
          ],
        ),
      );
    }

    // إضافة الأسطر الفارغة المتبقية مع الرسم القطري (الشطب)
    final emptyRowsCount = totalRows - records.length;
    for (int i = 0; i < emptyRowsCount; i++) {
      tableRows.add(
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 6),
              child: pw.Center(
                  child: pw.Text('٢٠  م / ٢٠  م',
                      style: pw.TextStyle(
                          font: font, fontSize: 10, color: PdfColors.grey700))),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 6),
              child: pw.Center(
                  child: pw.Text('في الصف',
                      style: pw.TextStyle(
                          font: fontBold, fontSize: 10, color: PdfColors.grey700))),
            ),
            pw.Container(height: 18),
          ],
        ),
      );
    }

    return pw.Stack(
      children: [
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.black, width: 0.8),
          columnWidths: {
            0: const pw.FlexColumnWidth(1.2),
            1: const pw.FlexColumnWidth(1.0),
            2: const pw.FlexColumnWidth(1.0),
          },
          children: tableRows,
        ),
        // رسم الخط المائل (الشطب) عبر الأسطر الفارغة إذا وجدت (طريقة رسم كتمويه رسم رسمي)
        if (emptyRowsCount > 0)
          pw.Positioned.fill(
            child: pw.CustomPaint(
              painter: (PdfGraphics canvas, PdfPoint size) {
                // حساب ارتفاع الخانات الفارغة في أسفل الجدول
                final double emptyHeight = (emptyRowsCount * 22.0);
                canvas
                  ..setStrokeColor(PdfColors.black)
                  ..setLineWidth(0.8)
                  ..drawLine(0, 0, size.x, emptyHeight)
                  ..strokePath();
              },
            ),
          ),
      ],
    );
  }
}