import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../models/grade_model.dart';
import '../services/student_service.dart';
import '../services/grade_service.dart';
import '../widgets/app_drawer.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  final StudentService _studentService = StudentService();
  final GradeService _gradeService = GradeService();

  String _selectedGrade = 'الأول الثانوي';
  String _selectedTerm = 'الفصل الأول';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أمانة السر - كشوفات العلامات والجلاءات'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // شريط الفلترة حسب الصف والفصل
          Container(
            padding: const EdgeInsets.all(12.0),
            color: Colors.purple.shade50,
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGrade,
                    items: ['الأول الثانوي', 'الثاني الثانوي', 'الثالث الثانوي']
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedGrade = val!),
                    decoration: const InputDecoration(
                      labelText: 'الصف الدراسي',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedTerm,
                    items: ['الفصل الأول', 'الفصل الثاني']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedTerm = val!),
                    decoration: const InputDecoration(
                      labelText: 'الفصل الدراسي',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // قائمة الطلاب لعرض/إدخال العلامات
          Expanded(
            child: StreamBuilder<List<StudentModel>>(
              stream: _studentService.getStudentsByGrade(_selectedGrade),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('لا يوجد طلاب مسجلون في هذا الصف'));
                }

                final students = snapshot.data!;

                return ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.purple,
                          child: Icon(Icons.assignment_turned_in, color: Colors.white),
                        ),
                        title: Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('الرقم الوطني: ${student.nationalId} | الشعبة: ${student.section}'),
                        trailing: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade700,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _showAddGradeDialog(student),
                          icon: const Icon(Icons.edit_note),
                          label: const Text('إدخال / جلاء'),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // نافذة إدخال علامات مادة للطالب
  void _showAddGradeDialog(StudentModel student) {
    final subjectController = TextEditingController();
    final examController = TextEditingController();
    final activityController = TextEditingController();
    final maxScoreController = TextEditingController(text: '100');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('رصد علامات: ${student.fullName}', textAlign: TextAlign.center),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(labelText: 'اسم المادة (مثل: رياضيات)'),
              ),
              TextField(
                controller: activityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'علامة النشاط / المذاكرة'),
              ),
              TextField(
                controller: examController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'علامة الامتحان النهائي'),
              ),
              TextField(
                controller: maxScoreController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'الدرجة العظمى للمادة'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (subjectController.text.isNotEmpty) {
                final grade = GradeModel(
                  id: '',
                  studentId: student.id,
                  studentName: student.fullName,
                  subject: subjectController.text,
                  term: _selectedTerm,
                  activityScore: double.tryParse(activityController.text) ?? 0.0,
                  examScore: double.tryParse(examController.text) ?? 0.0,
                  maxScore: double.tryParse(maxScoreController.text) ?? 100.0,
                );

                await _gradeService.saveGrade(grade);
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('حفظ العلامة'),
          ),
        ],
      ),
    );
  }
}