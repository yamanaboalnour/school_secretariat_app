import 'dart:convert';
import 'package:crypto/crypto.dart';

class HashHelper {
  /// تشفير كلمة السر باستخدام SHA-256 مع Salt مخصص لرفع مستوى الأمان
  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// إنشاء Salt عشوائي فريد لكل مستخدم
  static String generateSalt() {
    final now = DateTime.now().microsecondsSinceEpoch.toString();
    final bytes = utf8.encode(now);
    return sha256.convert(bytes).toString().substring(0, 16);
  }
}