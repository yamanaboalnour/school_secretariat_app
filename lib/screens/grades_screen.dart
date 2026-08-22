import 'package:flutter/material.dart';

/// Compatibility entry point kept until a class-wide grades page is added.
class GradesScreen extends StatelessWidget {
  const GradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('كشوفات العلامات والجلاءات')),
      body: const Center(
        child: Text('افتح كشف العلامات من زر الدرجات بجانب الطالب.'),
      ),
    );
  }
}
