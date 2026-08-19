import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/student_model.dart';
import 'academic_sequence_pdf.dart'; // 👈 استيراد شاشة طباعة الـ PDF

class StudentsListScreen extends StatefulWidget {
  const StudentsListScreen({Key? key}) : super(key: key);

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  List<Student> _allStudents = [];
  List<Student> _filteredStudents = [];
  bool _isLoading = true;

  String _searchQuery = '';
  String _selectedGrade = 'الكل';

  @override
  void initState() {
    super.initState();
    _loadAndMergeData();
  }

  // تحميل ودمج بيانات السجل العام وسجل النتائج
  Future<void> _loadAndMergeData() async {
    try {
      // 1. تحميل السجل العام
      final rawGeneral = await rootBundle.loadString('assets/MASTER GENERAL REGISTER OF STUDENTS.csv');
      List<List<dynamic>> generalData = const CsvToListConverter(
        fieldDelimiter: ';',
        shouldParseNumbers: false,
      ).convert(rawGeneral);

      Map<String, Student> studentMap = {};

      for (int i = 1; i < generalData.length; i++) {
        final row = generalData[i];
        if (row.length < 10) continue;

        String id = row[0].toString().trim();
        String rawGrade = row[10].toString().replaceAll('.0', '').trim();

        studentMap[id] = Student(
          generalId: id,
          nationalId: row[1].toString(),
          fullName: row[9].toString() != 'فارغ فارغ' ? row[9].toString() : '${row[7]} ${row[8]}',
          firstName: row[7].toString(),
          lastName: row[8].toString(),
          fatherName: row[12].toString(),
          motherName: row[14].toString(),
          grade: _mapGradeToText(rawGrade),
          section: row[11].toString(),
          birthDate: row[17].toString(),
          birthPlace: row[16].toString(),
          address: row[22].toString(),
          studentMobile: row[48].toString(),
          fatherMobile: row[54].toString(),
          approvedWhatsapp: row[72].toString().isNotEmpty ? row[72].toString() : row[55].toString(),
          status: row[5].toString(),
          previousSchool: row[28].toString(),
        );
      }

      // 2. تحميل ملف نتائج السنوات والدمج مع الفاصلة المنقوطة
      final rawResults = await rootBundle.loadString('assets/Record the results of the years for students.csv');
      List<List<dynamic>> resultsData = const CsvToListConverter(
        fieldDelimiter: ';',
        shouldParseNumbers: false,
      ).convert(rawResults);

      if (resultsData.isNotEmpty) {
        final headers = resultsData[0].map((e) => e.toString().trim()).toList();

        for (int i = 1; i < resultsData.length; i++) {
          final row = resultsData[i];
          if (row.isEmpty) continue;

          String id = row[0].toString().trim();

          if (studentMap.containsKey(id)) {
            for (int j = 5; j < row.length && j < headers.length; j++) {
              String val = row[j].toString().trim();
              if (val.isNotEmpty && val != 'null') {
                studentMap[id]!.academicHistory[headers[j]] = val;
              }
            }
          }
        }
      }

      setState(() {
        _allStudents = studentMap.values.toList();
        _filteredStudents = _allStudents;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading/merging data: $e");
      setState(() => _isLoading = false);
    }
  }

  String _mapGradeToText(String grade) {
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

  void _filterStudents() {
    setState(() {
      _filteredStudents = _allStudents.where((s) {
        final normalizedSearch = _normalizeText(_searchQuery);
        final normalizedName = _normalizeText(s.fullName);
        final normalizedId = s.generalId;

        final matchesSearch = normalizedSearch.isEmpty ||
            normalizedName.contains(normalizedSearch) ||
            normalizedId.contains(normalizedSearch);

        final matchesGrade = _selectedGrade == 'الكل' || s.grade == _selectedGrade;

        return matchesSearch && matchesGrade;
      }).toList();
    });
  }

  String _normalizeText(String text) {
    return text
        .replaceAll(RegExp(r'[أإآا]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .trim()
        .toLowerCase();
  }

  void _openWhatsapp(String phone) async {
    if (phone.isEmpty) return;
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final url = Uri.parse("https://wa.me/$cleanPhone");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('السجل العام (${_filteredStudents.length} طالب)'),
          centerTitle: true,
          backgroundColor: Colors.teal[800],
          foregroundColor: Colors.white,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.teal[50],
                    child: Column(
                      children: [
                        TextField(
                          onChanged: (val) {
                            _searchQuery = val;
                            _filterStudents();
                          },
                          decoration: InputDecoration(
                            labelText: 'بحث بالاسم الكامل أو الرقم العام...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ['الكل', 'السابع', 'الثامن', 'التاسع', 'العاشر', 'الحادي عشر', 'الثاني عشر']
                                .map((grade) => Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: FilterChip(
                                        label: Text(grade),
                                        selected: _selectedGrade == grade,
                                        onSelected: (selected) {
                                          _selectedGrade = grade;
                                          _filterStudents();
                                        },
                                      ),
                                    ))
                                .toList(),
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: _filteredStudents.isEmpty
                        ? const Center(child: Text('لا يوجد طلاب مطابقون للشروط'))
                        : ListView.builder(
                            itemCount: _filteredStudents.length,
                            padding: const EdgeInsets.all(8),
                            itemBuilder: (context, index) {
                              final student = _filteredStudents[index];
                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.teal[700],
                                    foregroundColor: Colors.white,
                                    child: Text(student.generalId),
                                  ),
                                  title: Text(
                                    student.fullName,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    'الصف: ${student.grade} | الشعبة: ${student.section.isNotEmpty ? student.section : "-"} | الأب: ${student.fatherName}',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (student.approvedWhatsapp.isNotEmpty && student.approvedWhatsapp != 'null')
                                        IconButton(
                                          icon: const Icon(Icons.chat, color: Colors.green),
                                          tooltip: 'مراسلة واتساب',
                                          onPressed: () => _openWhatsapp(student.approvedWhatsapp),
                                        ),
                                      const Icon(Icons.arrow_forward_ios, size: 16),
                                    ],
                                  ),
                                  onTap: () => _showStudentDetailsModal(context, student),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showStudentDetailsModal(BuildContext context, Student student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(student.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal)),
                const Divider(),
                _detailRow('الرقم العام:', student.generalId),
                _detailRow('الرقم الوطني:', student.nationalId),
                _detailRow('اسم الأم:', student.motherName),
                _detailRow('تاريخ الولادة:', student.birthDate),
                _detailRow('مكان السكن:', student.address),
                _detailRow('جوال الأب / الولي:', student.fatherMobile),
                _detailRow('واتساب المعتمد:', student.approvedWhatsapp),
                _detailRow('حالة الدوام:', student.status),
                const SizedBox(height: 16),
                
                // قسم السجل الأكاديمي
                const Text(
                  '📚 السجل الأكاديمي (الأرشيف):',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
                const SizedBox(height: 8),
                student.academicHistory.isEmpty
                    ? const Text('لا توجد سجلات نتائج مسجلة.', style: TextStyle(color: Colors.grey))
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: student.academicHistory.entries.map((e) {
                          bool isPassed = e.value.contains('ناجح');
                          return Chip(
                            backgroundColor: isPassed ? Colors.green[50] : Colors.red[50],
                            side: BorderSide(color: isPassed ? Colors.green : Colors.red),
                            label: Text(
                              '${e.key}: ${e.value}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isPassed ? Colors.green[900] : Colors.red[900],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                const SizedBox(height: 20),

                // 🆕 زر طباعة وثيقة التسلسل الدراسي
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.print),
                    label: const Text('استخراج وثيقة تسلسل دراسي (PDF)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.pop(context); // إغلاق النافذة المنبثقة
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AcademicSequencePdfScreen(student: student),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(width: 8),
          Expanded(child: Text(value.isNotEmpty && value != 'null' ? value : 'غير مدخل', style: const TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }
}