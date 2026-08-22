import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student_model.dart';
import '../providers/student_provider.dart';
import 'edit_student_screen.dart';

class StudentsListScreen extends StatelessWidget {
  final Function(Student)? onGenerateSequence;

  const StudentsListScreen({super.key, this.onGenerateSequence});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة الطلاب'),
      ),
      body: Consumer<StudentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.students.isEmpty) {
            return const Center(child: Text('لا يوجد طلاب مسجلون'));
          }

          return ListView.builder(
            itemCount: provider.students.length,
            itemBuilder: (context, index) {
              final student = provider.students[index];
              return ListTile(

                title: Text(student.fullName),
                subtitle: Text('الصف: ${student.latestGrade} - الحالة: ${student.latestStatus}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                      onPressed: () {
                        if (onGenerateSequence != null) {
                          onGenerateSequence!(student);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
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
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(context, provider, student),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, StudentProvider provider, Student student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت تأكد من حذف الطالب ${student.fullName}؟'),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
            onPressed: () {
              provider.deleteStudent(student.generalId);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}