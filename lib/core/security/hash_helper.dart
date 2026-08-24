import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:crypto/crypto.dart';

class HashHelper {
  static const legacySha256 = 'sha256';
  static const pbkdf2Sha256V1 = 'pbkdf2_sha256_v1';
  static const _pbkdf2Iterations = 120000;

  /// اشتقاق بطيء مخصص لكلمات المرور بدلاً من استخدام SHA-256 مباشرة.
  static Future<String> hashPassword(String password, String salt) async {
    final key = await Pbkdf2.hmacSha256(
      iterations: _pbkdf2Iterations,
      bits: 256,
    ).deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: base64Url.decode(salt),
    );
    return base64UrlEncode(await key.extractBytes());
  }

  /// التوافق مع الحسابات التي أُنشئت قبل اعتماد PBKDF2.
  static String hashLegacyPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<bool> verifyPassword({
    required String password,
    required String salt,
    required String passwordHash,
    required String algorithm,
  }) async {
    final computedHash = algorithm == pbkdf2Sha256V1
        ? await hashPassword(password, salt)
        : hashLegacyPassword(password, salt);
    return _constantTimeEquals(computedHash, passwordHash);
  }

  static bool isValidNewPassword(String password) {
    if (password.length < 12) return false;

    var groups = 0;
    if (RegExp(r'[a-z]').hasMatch(password)) groups++;
    if (RegExp(r'[A-Z]').hasMatch(password)) groups++;
    if (RegExp(r'[0-9]').hasMatch(password)) groups++;
    if (RegExp(r'[^a-zA-Z0-9]').hasMatch(password)) groups++;
    return groups >= 3;
  }

  static String newPasswordValidationMessage() {
    return 'كلمة المرور يجب أن تحتوي 12 محرفًا على الأقل ومن ثلاثة أنواع: '
        'أحرف صغيرة أو كبيرة أو أرقام أو رموز.';
  }

  /// إنشاء Salt عشوائي فريد لكل مستخدم
  static String generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  static bool _constantTimeEquals(String left, String right) {
    if (left.length != right.length) return false;
    var difference = 0;
    for (var index = 0; index < left.length; index++) {
      difference |= left.codeUnitAt(index) ^ right.codeUnitAt(index);
    }
    return difference == 0;
  }
}
