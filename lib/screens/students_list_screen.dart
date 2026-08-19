import 'package:flutter/material.dart';
import '../models/student_model.dart';
import 'academic_sequence_pdf.dart';
import 'student_card_pdf.dart';

class StudentsListScreen extends StatefulWidget {
  final List<Student> students;

  const StudentsListScreen({Key? key, required this.students}) : super(key: key);

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  late List<Student> _studentList;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _studentList = List.from(widget.students);
  }

  List<Student> get _filteredStudents {
    if (_searchQuery.isEmpty) return _studentList;
    return _studentList.where((s) {
      return s.fullName.contains(_searchQuery) ||
          s.generalId.contains(_searchQuery) ||
          s.fatherName.contains(_searchQuery);
    }).toList();
  }

  // 1. نافذة إضافة/تعديل طالب
  void _showStudentDialog({Student? student, int? index}) {
    final idController = TextEditingController(text: student?.generalId ?? '');
    final nameController = TextEditingController(text: student?.fullName ?? '');
    final fatherController = TextEditingController(text: student?.fatherName ?? '');
    final motherController = TextEditingController(text: student?.motherName ?? '');
    final birthPlaceController = TextEditingController(text: student?.birthPlace ?? '');
    final birthDateController = TextEditingController(text: student?.birthDate ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(student == null ? 'إضافة طالب جديد' : 'تعديل بيانات الطالب'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: idController, decoration: const InputDecoration(labelText: 'الرقم العام')),
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'اسم الطالب الكامل')),
                TextField(controller: fatherController, decoration: const InputDecoration(labelText: 'اسم الأب')),
                TextField(controller: motherController, decoration: const InputDecoration(labelText: 'اسم الأم')),
                TextField(controller: birthPlaceController, decoration: const InputDecoration(labelText: 'مكان الولادة')),
                TextField(controller: birthDateController, decoration: const InputDecoration(labelText: 'تاريخ الميلاد')),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B3B2B)),
              onPressed: () {
                if (idController.text.isEmpty || nameController.text.isEmpty) return;

                final newStudent = Student(
                  generalId: idController.text,
                  fullName: nameController.text,
                  fatherName: fatherController.text,
                  motherName: motherController.text,
                  birthPlace: birthPlaceController.text,
                  birthDate: birthDateController.text,
                  academicHistory: student?.academicHistory ?? {},
                );

                setState(() {
                  if (student == null) {
                    _studentList.add(newStudent);
                  } else if (index != null) {
                    _studentList[index] = newStudent;
                  }
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(student == null ? 'تمت إضافة الطالب بنجاح' : 'تم تعديل البيانات بنجاح')),
                );
              },
              child: const Text('حفظ', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // 2. حذف طالب
  void _deleteStudent(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت تأكد من حذف الطالب: ${_studentList[index].fullName}؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                _studentList.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف الطالب من السجل')),
              );
            },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1B3B2B);

    return Scaffold(
      appBar: AppBar(
        title: const Text('السجل العام للطلاب'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryGreen,
        onPressed: () => _showStudentDialog(),
        child: const Icon(Icons.person_add_rounded, color: Colors.white),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // شريط البحث
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  labelText: 'بحث بالاسم أو الرقم العام...',
                  prefixIcon: const Icon(Icons.search, color: primaryGreen),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            // قائمة الطلاب
            Expanded(
              child: ListView.builder(
                itemCount: _filteredStudents.length,
                itemBuilder: (context, i) {
                  final student = _filteredStudents[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: primaryGreen.withOpacity(0.1),
                        child: Text(student.generalId, style: const TextStyle(color: primaryGreen, fontSize: 11)),
                      ),
                      title: Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('الأب: ${student.fatherName} | الصف: ${student.latestGrade}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // طباعة بطاقة الطالب (الكارنيه)
                          IconButton(
                            icon: const Icon(Icons.badge_rounded, color: primaryGreen),
                            tooltip: 'طباعة البطاقة المدرسية',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudentCardPdfScreen(student: student),
                                ),
                              );
                            },
                          ),
                          // طباعة وثيقة تسلسل دراسي
                          IconButton(
                            icon: const Icon(Icons.description_rounded, color: Colors.teal),
                            tooltip: 'وثيقة تسلسل دراسي',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AcademicSequencePdfScreen(student: student),
                                ),
                              );
                            },
                          ),
                          // تعديل
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, color: Colors.orange),
                            onPressed: () => _showStudentDialog(student: student, index: i),
                          ),
                          // حذف
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                            onPressed: () => _deleteStudent(i),
                          ),
                        ],
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