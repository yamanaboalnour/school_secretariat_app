import 'package:flutter/material.dart';
import '../data/backup_service.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('النسخ الاحتياطي واستعادة البيانات'),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'تنبيه: يُنصح بأخذ نسخة احتياطية بشكل دوري وحفظها في مكان آمن (مثل قرص خارجي) لضمان عدم فقدان بيانات الطلاب والوثائق.',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                icon: const Icon(Icons.download),
                label: const Text('تصدير نسخة احتياطية الان', style: TextStyle(fontSize: 16)),
                onPressed: _isLoading ? null : () => _handleExport(context),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  foregroundColor: Colors.red,
                ),
                icon: const Icon(Icons.upload),
                label: const Text('استعادة نسخة احتياطية', style: TextStyle(fontSize: 16)),
                onPressed: _isLoading ? null : () => _handleRestore(context),
              ),
              const SizedBox(height: 20),
              if (_isLoading) const Center(child: CircularProgressIndicator()),
              if (_statusMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleExport(BuildContext context) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'جاري تصدير النسخة الاحتياطية...';
    });

    try {
      // كمثال: حفظ في مجلد المستندات المحلي
      final destinationDir = '/Users/public/Documents'; 
      final file = await BackupService.exportBackup(destinationDir);
      setState(() {
        _statusMessage = 'تم التصدير بنجاح إلى: ${file.path}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'فشل التصدير: ${e.toString()}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRestore(BuildContext context) async {
    // إجراء استعادة البيانات يتطلب حذر لتجنب الفقدان غير المقصود
    setState(() {
      _statusMessage = 'ميزة تحديد الملف تفاعلياً تستدعي حزمة file_picker.';
    });
  }
}