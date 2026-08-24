import 'package:flutter_test/flutter_test.dart';
import 'package:school_secretariat_app/core/security/hash_helper.dart';

void main() {
  group('HashHelper', () {
    test('uses PBKDF2 for new passwords and verifies them', () async {
      const password = 'School!2026Pass';
      const salt = 'c2VjdXJlLXNhbHQ=';
      final hash = await HashHelper.hashPassword(password, salt);

      expect(hash, isNot(password));
      expect(
        await HashHelper.verifyPassword(
          password: password,
          salt: salt,
          passwordHash: hash,
          algorithm: HashHelper.pbkdf2Sha256V1,
        ),
        isTrue,
      );
      expect(
        await HashHelper.verifyPassword(
          password: 'Wrong!2026Pass',
          salt: salt,
          passwordHash: hash,
          algorithm: HashHelper.pbkdf2Sha256V1,
        ),
        isFalse,
      );
    });

    test('continues to verify a legacy hash for safe migration', () async {
      const password = 'old-password';
      const salt = 'c2VjdXJlLXNhbHQ=';
      final hash = HashHelper.hashLegacyPassword(password, salt);

      expect(
        await HashHelper.verifyPassword(
          password: password,
          salt: salt,
          passwordHash: hash,
          algorithm: HashHelper.legacySha256,
        ),
        isTrue,
      );
    });

    test('requires a long password with a varied character mix', () {
      expect(HashHelper.isValidNewPassword('School!2026Pass'), isTrue);
      expect(HashHelper.isValidNewPassword('alllowercase12'), isFalse);
      expect(HashHelper.isValidNewPassword('Short!1'), isFalse);
    });
  });
}
