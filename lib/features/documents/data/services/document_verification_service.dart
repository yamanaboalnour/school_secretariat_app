import 'package:crypto/crypto.dart';

class DocumentVerificationService {
  static String createToken({
    required int studentId,
    required String studentName,
    required String serial,
    required String documentType,
  }) {
    final raw = '$studentId|$serial|$studentName|$documentType';
    final signature = sha256.convert(raw.codeUnits).toString();
    return 'school_secretariat|$serial|$signature';
  }

  static bool verifyToken({
    required String token,
    required int studentId,
    required String studentName,
    required String documentType,
  }) {
    final parts = token.split('|');
    if (parts.length != 3 || parts.first != 'school_secretariat') {
      return false;
    }
    final expected = createToken(
      studentId: studentId,
      studentName: studentName,
      serial: parts[1],
      documentType: documentType,
    );
    return _constantTimeEquals(token, expected);
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
