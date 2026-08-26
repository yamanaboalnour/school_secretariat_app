import 'package:flutter/material.dart';

import 'features/academic_sequence/presentation/pages/academic_sequence_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const SchoolSecretariatApp(),
  );
}

class SchoolSecretariatApp extends StatelessWidget {
  const SchoolSecretariatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'أمانة السر المدرسية',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: const AcademicSequencePage(),
    );
  }
}