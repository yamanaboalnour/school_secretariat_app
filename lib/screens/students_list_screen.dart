import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student_model.dart';
import '../providers/student_provider.dart';
import 'academic_sequence_pdf.dart';
import 'edit_student_screen.dart';

class StudentsListScreen extends StatefulWidget {
  final Function(Student)? onGenerateSequence;

  const StudentsListScreen({Key? key, this.onGenerateSequence}) : super(key: key);

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1B3B2B);

    return Scaffold(
      appBar: AppBar(
        title: const Text('السجل العام للطلاب'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        tooltip: 'إضافة طالب جديد',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditStudentScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Consumer<StudentProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final filteredStudents = provider.students.where((s) {
              return s.fullName.contains(_searchQuery) ||
                  s.generalId.contains(_searchQuery) ||
                  s.fatherName.contains(_searchQuery);
            }).toList();

            return Column(
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
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      tooltip: 'تعديل البيانات',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditStudentScreen(student: student),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.print_rounded, color: primaryGreen),
                                      tooltip: 'معاينة وطباعة التسلسل',
                                      onPressed: () {
                                        if (widget.onGenerateSequence != null) {
                                          widget.onGenerateSequence!(student);
                                        }
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AcademicSequencePdfScreen(student: student),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}git add .
git commit -m "Add EditStudentScreen and connect CRUD operations to SQLite via Provider"
git push