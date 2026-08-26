import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../students/data/repositories/student_repository.dart';
import '../../data/services/document_verification_service.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  final StudentRepository _studentRepository = StudentRepository();
  String? _resultMessage;
  bool _isProcessing = false;

  Future<void> _handleCode(String value) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final parts = value.split('|');
      final serialParts = parts.length > 1 ? parts[1].split('-') : <String>[];
      final documentType = serialParts.length > 2 ? serialParts[1] : null;
      final studentId =
          serialParts.length > 2 ? int.tryParse(serialParts[2]) : null;
      if (parts.length != 3 || studentId == null) {
        throw const FormatException('رمز الوثيقة غير صالح.');
      }

      final student = await _studentRepository.getStudentById(studentId);
      if (!mounted) return;
      final isValid = student != null &&
          DocumentVerificationService.verifyToken(
            token: value,
            studentId: student.id!,
            studentName: '${student.firstName} ${student.lastName}',
            documentType:
                documentType == 'report_card' ? 'report_card' : 'sequence',
          );
      setState(() {
        _resultMessage = isValid
            ? 'الوثيقة صحيحة: ${student.firstName} ${student.lastName}'
            : 'تعذر التحقق من صحة الوثيقة.';
        _isProcessing = false;
      });
      await _controller.stop();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _resultMessage = 'خطأ في قراءة الوثيقة: $error';
        _isProcessing = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التحقق من وثيقة QR')),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                final value = capture.barcodes.isEmpty
                    ? null
                    : capture.barcodes.first.rawValue;
                if (value != null) _handleCode(value);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _resultMessage ?? 'وجّه الكاميرا نحو رمز QR في الوثيقة.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _resultMessage?.startsWith('الوثيقة صحيحة') == true
                    ? Colors.green
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
