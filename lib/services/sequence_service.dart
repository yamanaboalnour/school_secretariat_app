import 'package:shared_preferences/shared_preferences.dart';

class SequenceService {
  static const String _keyLastSequence = 'last_issued_sequence';

  // الحصول على الرقم القادم دون حفظه
  static Future<int> getNextSequenceNumber() async {
    final prefs = await SharedPreferences.getInstance();
    int lastSeq = prefs.getInt(_keyLastSequence) ?? 1000;
    return lastSeq + 1;
  }

  // حفظ الرقم وتثبيته فقط عند أمر الطباعة
  static Future<int> issueAndSaveSequenceNumber() async {
    final prefs = await SharedPreferences.getInstance();
    int lastSeq = prefs.getInt(_keyLastSequence) ?? 1000;
    int newSeq = lastSeq + 1;
    await prefs.setInt(_keyLastSequence, newSeq);
    return newSeq;
  }
}