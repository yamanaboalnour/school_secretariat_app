import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/student_bloc.dart';
import '../../data/datasources/excel_service.dart';
import '../../data/models/student_model.dart';
import '../../../grades/presentation/pages/student_grades_page.dart';
import 'add_student_page.dart';
import '../../../documents/presentation/pages/document_preview_page.dart';

class StudentsListPage extends StatelessWidget {
  const StudentsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة سجلات الطلاب'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'تصدير الطلاب إلى Excel',
            onPressed: () async {
              final state = context.read<StudentBloc>().state;
              if (state is! StudentLoadedState || state.students.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('لا توجد بيانات طلاب لتصديرها.')),
                );
                return;
              }

              try {
                final saved = await ExcelService.exportStudentsToExcel(
                  state.students,
                );
                if (!context.mounted || !saved) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تصدير قائمة الطلاب بنجاح.')),
                );
              } catch (error) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('فشل تصدير الملف: $error')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_upload),
            tooltip: 'استيراد طلاب من ملف Excel',
            onPressed: () async {
              try {
                final importedStudents =
                    await ExcelService.importStudentsFromExcel();
                if (!context.mounted || importedStudents.isEmpty) {
                  return;
                }

                for (final student in importedStudents) {
                  context.read<StudentBloc>().add(AddStudentEvent(student));
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم استيراد ${importedStudents.length} طالب بنجاح!',
                    ),
                  ),
                );
              } catch (error) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('فشل استيراد الملف: $error')),
                );
              }
            },
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'بحث عن طالب (الاسم، اسم الأب، الرقم الوطني)...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (query) {
                  context
                      .read<StudentBloc>()
                      .add(LoadStudentsEvent(query: query));
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<StudentBloc, StudentState>(
                builder: (context, state) {
                  if (state is StudentLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is StudentLoadedState) {
                    if (state.students.isEmpty) {
                      return const Center(
                          child: Text('لا يوجد طلاب مسجلون حالياً.'));
                    }
                    return ListView.builder(
                      itemCount: state.students.length,
                      itemBuilder: (context, index) {
                        final student = state.students[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(student.firstName.isNotEmpty
                                  ? student.firstName[0]
                                  : '?'),
                            ),
                            title: Text(
                                '${student.firstName} ${student.lastName}'),
                            subtitle: Text(
                                'الأب: ${student.fatherName} | الصف: ${student.gradeLevel}'),
                            // --- أزرار التحكم بالسطر (الطباعة + الحذف) ---
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  tooltip: 'تعديل بيانات الطالب',
                                  onPressed: () =>
                                      _editStudent(context, student),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.grade,
                                      color: Colors.orange),
                                  tooltip: 'كشف العلامات والدرجات',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            StudentGradesPage(student: student),
                                      ),
                                    );
                                  },
                                ),
                                // زر الطباعة
                                IconButton(
                                  icon: const Icon(Icons.print,
                                      color: Colors.indigo),
                                  tooltip: 'طباعة وثيقة',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DocumentPreviewPage(
                                            student: student),
                                      ),
                                    );
                                  },
                                ),
                                // زر الحذف
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  tooltip: 'حذف الطالب',
                                  onPressed: () {
                                    if (student.id != null) {
                                      context
                                          .read<StudentBloc>()
                                          .add(DeleteStudentEvent(student.id!));
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is StudentErrorState) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<StudentBloc>(),
                child: const AddStudentPage(),
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('إضافة طالب'),
      ),
    );
  }

  Future<void> _editStudent(BuildContext context, StudentModel student) async {
    final firstName = TextEditingController(text: student.firstName);
    final lastName = TextEditingController(text: student.lastName);
    final fatherName = TextEditingController(text: student.fatherName);
    final motherName = TextEditingController(text: student.motherName);
    final gradeLevel = TextEditingController(text: student.gradeLevel);
    final nationalId = TextEditingController(text: student.nationalId ?? '');

    final updated = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تعديل بيانات الطالب'),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final field in [
                  (firstName, 'الاسم الأول'),
                  (lastName, 'الكنية'),
                  (fatherName, 'اسم الأب'),
                  (motherName, 'اسم الأم'),
                  (nationalId, 'الرقم الوطني'),
                  (gradeLevel, 'الصف'),
                ])
                  TextField(
                    controller: field.$1,
                    decoration: InputDecoration(labelText: field.$2),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              context.read<StudentBloc>().add(
                    UpdateStudentEvent(
                      StudentModel(
                        id: student.id,
                        firstName: firstName.text.trim(),
                        lastName: lastName.text.trim(),
                        fatherName: fatherName.text.trim(),
                        motherName: motherName.text.trim(),
                        nationalId: nationalId.text.trim().isEmpty
                            ? null
                            : nationalId.text.trim(),
                        birthDate: student.birthDate,
                        gradeLevel: gradeLevel.text.trim(),
                        registrationDate: student.registrationDate,
                        createdAt: student.createdAt,
                      ),
                    ),
                  );
              Navigator.pop(dialogContext, true);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    firstName.dispose();
    lastName.dispose();
    fatherName.dispose();
    motherName.dispose();
    gradeLevel.dispose();
    nationalId.dispose();
    if (updated == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تعديل بيانات الطالب.')),
      );
    }
  }
}
