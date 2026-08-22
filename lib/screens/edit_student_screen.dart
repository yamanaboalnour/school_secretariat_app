import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student_model.dart';
import '../providers/student_provider.dart';

class EditStudentScreen extends StatefulWidget {
  final Student? student; // إذا كان null فهذا يعني إضافة طالب جديد

  const EditStudentScreen({Key? key, this.student}) : super(key: key);

  @override
  State<EditStudentScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _fatherController;
  late TextEditingController _motherController;
  late TextEditingController _birthPlaceController;
  late TextEditingController _birthDateController;
  late TextEditingController _gradeController;
  late TextEditingController _statusController;

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    _idController = TextEditingController(text: s?.generalId ?? '');
    _nameController = TextEditingController(text: s?.fullName ?? '');
    _fatherController = TextEditingController(text: s?.fatherName ?? '');
    _motherController = TextEditingController(text: s?.motherName ?? '');
    _birthPlaceController = TextEditingController(text: s?.birthPlace ?? '');
    _birthDateController = TextEditingController(text: s?.birthDate ?? '');
    _gradeController = TextEditingController(text: s?.latestGrade ?? 'العاشر');
    _statusController = TextEditingController(text: s?.latestStatus ?? 'مستجد');
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _fatherController.dispose();
    _motherController.dispose();
    _birthPlaceController.dispose();
    _birthDateController.dispose();
    _gradeController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final newStudent = Student(
        generalId: _idController.text.trim(),
        fullName: _nameController.text.trim(),
        fatherName: _fatherController.text.trim(),
        motherName: _motherController.text.trim(),
        birthPlace: _birthPlaceController.text.trim(),
        birthDate: _birthDateController.text.trim(),
        latestGrade: _gradeController.text.trim(),
        latestStatus: _statusController.text.trim(),
      );

      final provider = Provider.of<StudentProvider>(context, listen: false);

      if (widget.student == null) {
        provider.addStudent(newStudent);
      } else {
        provider.updateStudent(newStudent);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1B3B2B);
    final isEditing = widget.student != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'تعديل بيانات طالب' : 'إضافة طالب جديد'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _idController,
                  enabled: !isEditing, // الرقم العام لا يُعدّل إذا كان كائناً موجهاً
                  decoration: const InputDecoration(labelText: 'الرقم العام (ID)', border: OutlineInputBorder()),
                  validator: (v) => v == null || v.isEmpty ? 'هذا الحقل مطلوب' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'الاسم الكامل', border: OutlineInputBorder()),
                  validator: (v) => v == null || v.isEmpty ? 'هذا الحقل مطلوب' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _fatherController,
                  decoration: const InputDecoration(labelText: 'اسم الأب', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _motherController,
                  decoration: const InputDecoration(labelText: 'اسم الأم', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _birthPlaceController,
                        decoration: const InputDecoration(labelText: 'مكان الولادة', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _birthDateController,
                        decoration: const InputDecoration(labelText: 'تاريخ الولادة', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _gradeController,
                        decoration: const InputDecoration(labelText: 'الصف الدراسي', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _statusController,
                        decoration: const InputDecoration(labelText: 'الصفة / الوضع', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    isEditing ? 'حفظ التعديلات' : 'إضافة إلى قاعدة البيانات',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}