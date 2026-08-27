import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
  final _birthPlaceController = TextEditingController();
  final _birthDateController = TextEditingController();

  String? _selectedGrade;

  final List<String> _grades = const [
    'السابع',
    'الثامن',
    'التاسع',
    'العاشر',
    'الحادي عشر',
    'الباكلوريا',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _nationalIdController.dispose();
    _birthPlaceController.dispose();
    _birthDateController.dispose();

    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final initialDate = DateTime(2010);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
    );

    if (selectedDate == null) {
      return;
    }

    _birthDateController.text =
        DateFormat('dd/MM/yyyy').format(selectedDate);
  }

  void _saveStudent() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final now = DateTime.now().toIso8601String();

    final newStudent = StudentModel(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      fatherName: _fatherNameController.text.trim(),
      motherName: _motherNameController.text.trim(),
      nationalId: _nationalIdController.text.trim().isEmpty
          ? null
          : _nationalIdController.text.trim(),
      birthPlace: _birthPlaceController.text.trim().isEmpty
          ? null
          : _birthPlaceController.text.trim(),
      birthDate: _birthDateController.text.trim().isEmpty
          ? null
          : _birthDateController.text.trim(),
      gradeLevel: _selectedGrade!,
      registrationDate: now,
      createdAt: now,
    );

    context.read<StudentBloc>().add(
          AddStudentEvent(newStudent),
        );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة طالب جديد'),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'الاسم الأول *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'اسم الطالب مطلوب';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'النسبة / الكنية *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'النسبة / الكنية مطلوبة';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _fatherNameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم الأب *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'اسم الأب مطلوب';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _motherNameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم الأم *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'اسم الأم مطلوب';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _birthPlaceController,
                  decoration: const InputDecoration(
                    labelText: 'مكان الولادة',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _birthDateController,
                  readOnly: true,
                  onTap: _selectBirthDate,
                  decoration: const InputDecoration(
                    labelText: 'تاريخ الولادة',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_month),
                  ),
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _nationalIdController,
                  decoration: const InputDecoration(
                    labelText: 'الرقم الوطني / السجل',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: _selectedGrade,
                  decoration: const InputDecoration(
                    labelText: 'الصف الدراسي *',
                    border: OutlineInputBorder(),
                  ),
                  items: _grades.map((grade) {
                    return DropdownMenuItem<String>(
                      value: grade,
                      child: Text(grade),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGrade = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'اختر الصف الدراسي';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _saveStudent,
                    icon: const Icon(Icons.save),
                    label: const Text(
                      'حفظ بيانات الطالب',
                      style: TextStyle(fontSize: 16),
                    ),
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