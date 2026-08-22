import 'dart:convert';
import 'dart:math';
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
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }
}