import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const SchoolSecretariatApp());
}

class SchoolSecretariatApp extends StatelessWidget {
  const SchoolSecretariatApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ثانوية الشيخ عبد الكريم الرفاعي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0D5C3A),
        fontFamily: 'Cairo',
      ),
      home: const SplashScreen(),
    );
  }
}