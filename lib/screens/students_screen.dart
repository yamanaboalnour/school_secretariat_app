import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/students/data/repositories/student_repository.dart';
import '../features/students/presentation/bloc/student_bloc.dart';
import '../features/students/presentation/pages/students_list_page.dart';

/// Compatibility entry point for older navigation paths.
class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StudentBloc(StudentRepository())..add(LoadStudentsEvent()),
      child: const StudentsListPage(),
    );
  }
}
