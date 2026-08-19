import 'package:flutter/material.dart';
import '../models/student_model.dart';
import 'academic_sequence_pdf.dart';

class StudentsListScreen extends StatefulWidget {
  final List<Student> students;
  final Function(Student)? onGenerateSequence;

  const StudentsListScreen({
    Key? key,
    required this.students,
    this.onGenerateSequence,
  }) : super(key: key);

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1B3B2B);

    final filteredStudents = widget.students.where((s) {
      return s.fullName.contains(_searchQuery) ||
          s.generalId.contains(_searchQuery) ||
          s.fatherName.contains(_searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('السجل العام للطلاب'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'بحث برقم الطالب أو الاسم...',
                  prefixIcon: const Icon(Icons.search, color: primaryGreen),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Expanded(
              child: filteredStudents.isEmpty
                  ? const Center(child: Text('لا يوجد طلاب مطابقون للبحث'))
                  : ListView.builder(
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = filteredStudents[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: primaryGreen,
                              child: Text(
                                student.generalId,
                                style: const TextStyle(color: Colors.white, fontSize: 11),
                              ),
                            ),
                            title: Text(
                              student.fullName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('الأب: ${student.fatherName} | الصف: ${student.latestGrade}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.print_rounded, color: primaryGreen),
                              tooltip: 'معاينة وطباعة التسلسل',
                              onPressed: () {
                                // 1. تسليط العملية وحفظها في أرشيف السجلات
                                if (widget.onGenerateSequence != null) {
                                  widget.onGenerateSequence!(student);
                                }

                                // 2. فتح وثيقة الـ PDF
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AcademicSequencePdfScreen(student: student),
                                  ),
                                );
                              },
                            ),
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
}