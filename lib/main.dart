import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'features/auth/presentation/pages/auth_gate.dart';

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
      home: const AuthGate(),
    );
  }
}