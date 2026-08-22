import 'package:flutter/material.dart';
import 'core/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // تهيئة قاعدة البيانات عند تشغيل التطبيق
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
        fontFamily: 'Cairo', // يمكن إضافتها لاحقاً للتصميم العربي
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'نظام أمانة السر المدرسية - جاهز للتطوير',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}