import 'package:flutter/material.dart';
import '../models/sequence_log_model.dart';

class SequenceLogScreen extends StatelessWidget {
  final List<SequenceLog> logs;

  const SequenceLogScreen({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1B3B2B);

    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل وثائق التسلسل الدراسي'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: logs.isEmpty
            ? const Center(
                child: Text(
                  'لم يتم إصدار أي وثيقة تسلسل دراسي حتى الآن.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  final dateStr =
                      "${log.generatedAt.year}/${log.generatedAt.month}/${log.generatedAt.day} - ${log.generatedAt.hour}:${log.generatedAt.minute.toString().padLeft(2, '0')}";

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: primaryGreen,
                        child: Icon(Icons.history_edu, color: Colors.white),
                      ),
                      title: Text(
                        log.studentName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: primaryGreen,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'الرقم العام: ${log.generalId}\nتاريخ الإصدار: $dateStr',
                          style: const TextStyle(fontSize: 12, height: 1.4),
                        ),
                      ),
                      trailing: const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}