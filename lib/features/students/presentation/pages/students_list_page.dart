import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/student_bloc.dart';
import '../../data/models/student_model.dart';
import 'add_student_page.dart';

class StudentsListPage extends StatelessWidget {
  const StudentsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة سجلات الطلاب'),
        centerTitle: true,
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
                  context.read<StudentBloc>().add(LoadStudentsEvent(query: query));
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
                      return const Center(child: Text('لا يوجد طلاب مسجلون حالياً.'));
                    }
                    return ListView.builder(
                      itemCount: state.students.length,
                      itemBuilder: (context, index) {
                        final student = state.students[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(student.firstName[0]),
                            ),
                            title: Text('${student.firstName} ${student.lastName}'),
                            subtitle: Text('الأب: ${student.fatherName} | الصف: ${student.gradeLevel}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                if (student.id != null) {
                                  context.read<StudentBloc>().add(DeleteStudentEvent(student.id!));
                                }
                              },
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
}