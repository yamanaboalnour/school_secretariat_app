import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/database/database_helper.dart';
import 'features/students/data/repositories/student_repository.dart';
import 'features/students/presentation/bloc/student_bloc.dart';
import 'features/students/presentation/pages/students_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  runApp(const SchoolSecretariatApp());
}

class SchoolSecretariatApp extends StatelessWidget {
  const SchoolSecretariatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'أمانة السر المدرسية',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => StudentBloc(StudentRepository())..add(LoadStudentsEvent()),
        child: const StudentsListPage(),
      ),
    );
  }
}