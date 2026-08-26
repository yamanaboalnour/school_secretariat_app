import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/student_bloc.dart';
import '../../data/models/student_model.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _gradeLevelController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة طالب جديد')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'الاسم الأول *'),
                  validator: (v) => v!.isEmpty ? 'هذا الحقل مطلوب' : null,
                ),
                TextFormField(
                  controller: _lastNameController,
                  decoration:
                      const InputDecoration(labelText: 'النسبة / الكنية *'),
                  validator: (v) => v!.isEmpty ? 'هذا الحقل مطلوب' : null,
                ),
                TextFormField(
                  controller: _fatherNameController,
                  decoration: const InputDecoration(labelText: 'اسم الأب *'),
                  validator: (v) => v!.isEmpty ? 'هذا الحقل مطلوب' : null,
                ),
                TextFormField(
                  controller: _motherNameController,
                  decoration: const InputDecoration(labelText: 'اسم الأم *'),
                  validator: (v) => v!.isEmpty ? 'هذا الحقل مطلوب' : null,
                ),
                TextFormField(
                  controller: _nationalIdController,
                  decoration:
                      const InputDecoration(labelText: 'الرقم الوطني / السجل'),
                ),
                TextFormField(
                  controller: _gradeLevelController,
                  decoration: const InputDecoration(
                      labelText: 'الصف / المرحلة الدراسية *'),
                  validator: (v) => v!.isEmpty ? 'هذا الحقل مطلوب' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final newStudent = StudentModel(
                        firstName: _firstNameController.text,
                        lastName: _lastNameController.text,
                        fatherName: _fatherNameController.text,
                        motherName: _motherNameController.text,
                        nationalId: _nationalIdController.text.isEmpty
                            ? null
                            : _nationalIdController.text,
                        gradeLevel: _gradeLevelController.text,
                        registrationDate: DateTime.now().toIso8601String(),
                        createdAt: DateTime.now().toIso8601String(),
                      );
                      context
                          .read<StudentBloc>()
                          .add(AddStudentEvent(newStudent));
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('حفظ البيانات'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
