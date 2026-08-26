import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../core/security/hash_helper.dart';
import '../../../../database/database_helper.dart';
import '../../../settings/data/models/school_profile_model.dart';
import '../models/auth_user_model.dart';

class AuthRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<bool> requiresInitialSetup() async {
    final database = await _databaseHelper.database;
    final countRows =
        await database.rawQuery('SELECT COUNT(*) AS count FROM users');
    final count = (countRows.first['count'] as int?) ?? 0;
    if (count == 0) return true;

    final legacyDefaultRows = await database.rawQuery('''
      SELECT COUNT(*) AS count
      FROM users
      WHERE password_algorithm = ?
        AND ((username = ? AND full_name = ?)
          OR (username = ? AND full_name = ?))
    ''', [
      HashHelper.legacySha256,
      'admin',
      'مدير المدرسة',
      'secretary',
      'أمين السر',
    ]);
    final legacyDefaultCount = (legacyDefaultRows.first['count'] as int?) ?? 0;
    return legacyDefaultCount == count;
  }

  Future<AuthUserModel> completeInitialSetup({
    required String username,
    required String fullName,
    required String password,
    required SchoolProfileModel schoolProfile,
  }) async {
    final normalizedUsername = _validateUserDetails(
      username: username,
      fullName: fullName,
      password: password,
    );
    _validateSchoolProfile(schoolProfile);

    final salt = HashHelper.generateSalt();
    final passwordHash = await HashHelper.hashPassword(password, salt);
    final database = await _databaseHelper.database;

    return database.transaction((transaction) async {
      final countRows =
          await transaction.rawQuery('SELECT COUNT(*) AS count FROM users');
      final count = (countRows.first['count'] as int?) ?? 0;
      if (count > 0 &&
          !await _transactionHasOnlyLegacyDefaultUsers(transaction)) {
        throw StateError('تم إعداد التطبيق مسبقًا.');
      }

      await transaction.delete('users');
      final id = await transaction.insert('users', {
        'username': normalizedUsername,
        'full_name': fullName.trim(),
        'password_hash': passwordHash,
        'salt': salt,
        'password_algorithm': HashHelper.pbkdf2Sha256V1,
        'role': 'ADMIN',
        'is_active': 1,
      });
      await transaction.insert(
        'school_profile',
        schoolProfile.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return AuthUserModel(
        id: id,
        username: normalizedUsername,
        fullName: fullName.trim(),
        role: 'ADMIN',
        isActive: true,
      );
    });
  }

  Future<AuthUserModel?> login(String username, String password) async {
    final database = await _databaseHelper.database;
    final rows = await database.query(
      'users',
      columns: [
        'id',
        'username',
        'full_name',
        'role',
        'password_hash',
        'salt',
        'password_algorithm',
      ],
      where: 'username = ? AND is_active = 1',
      whereArgs: [username.trim()],
      limit: 1,
    );
    if (rows.isEmpty) return null;

    final user = rows.first;
    final algorithm =
        user['password_algorithm'] as String? ?? HashHelper.legacySha256;
    final passwordMatches = await HashHelper.verifyPassword(
      password: password,
      salt: user['salt'] as String,
      passwordHash: user['password_hash'] as String,
      algorithm: algorithm,
    );
    if (!passwordMatches) return null;

    if (algorithm != HashHelper.pbkdf2Sha256V1) {
      await _upgradeLegacyPassword(
        database: database,
        userId: user['id'] as int,
        password: password,
      );
    }
    return AuthUserModel.fromMap(user);
  }

  Future<AuthUserModel?> findByUsername(String username) async {
    final database = await _databaseHelper.database;
    final rows = await database.query(
      'users',
      columns: ['id', 'username', 'full_name', 'role', 'is_active'],
      where: 'username = ? AND is_active = 1',
      whereArgs: [username],
      limit: 1,
    );
    return rows.isEmpty ? null : AuthUserModel.fromMap(rows.first);
  }

  Future<List<AuthUserModel>> getUsers() async {
    final database = await _databaseHelper.database;
    final rows = await database.query(
      'users',
      columns: ['id', 'username', 'full_name', 'role', 'is_active'],
      orderBy: 'username COLLATE NOCASE ASC',
    );
    return rows.map(AuthUserModel.fromMap).toList();
  }

  Future<void> createUser({
    required String username,
    required String fullName,
    required String password,
    required String role,
  }) async {
    final normalizedUsername = _validateUserDetails(
      username: username,
      fullName: fullName,
      password: password,
    );
    final database = await _databaseHelper.database;
    final salt = HashHelper.generateSalt();
    final passwordHash = await HashHelper.hashPassword(password, salt);
    await database.insert('users', {
      'username': normalizedUsername,
      'full_name': fullName.trim(),
      'password_hash': passwordHash,
      'salt': salt,
      'password_algorithm': HashHelper.pbkdf2Sha256V1,
      'role': role,
      'is_active': 1,
    });
  }

  Future<void> changePassword({
    required String username,
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!HashHelper.isValidNewPassword(newPassword)) {
      throw FormatException(HashHelper.newPasswordValidationMessage());
    }
    final database = await _databaseHelper.database;
    final rows = await database.query(
      'users',
      columns: ['id', 'password_hash', 'salt', 'password_algorithm'],
      where: 'username = ? AND is_active = 1',
      whereArgs: [username],
      limit: 1,
    );
    if (rows.isEmpty) throw const FormatException('المستخدم غير موجود.');

    final user = rows.first;
    final algorithm =
        user['password_algorithm'] as String? ?? HashHelper.legacySha256;
    final passwordMatches = await HashHelper.verifyPassword(
      password: currentPassword,
      salt: user['salt'] as String,
      passwordHash: user['password_hash'] as String,
      algorithm: algorithm,
    );
    if (!passwordMatches) {
      throw const FormatException('كلمة المرور الحالية غير صحيحة.');
    }

    final salt = HashHelper.generateSalt();
    final passwordHash = await HashHelper.hashPassword(newPassword, salt);
    await database.update(
      'users',
      {
        'password_hash': passwordHash,
        'salt': salt,
        'password_algorithm': HashHelper.pbkdf2Sha256V1,
      },
      where: 'id = ?',
      whereArgs: [user['id']],
    );
  }

  Future<void> setUserActive(int userId, bool isActive) async {
    final database = await _databaseHelper.database;
    if (!isActive) {
      final activeAdmins = await database.rawQuery(
        "SELECT COUNT(*) AS count FROM users WHERE role = 'ADMIN' AND is_active = 1",
      );
      final adminCount = (activeAdmins.first['count'] as int?) ?? 0;
      final userRows = await database.query(
        'users',
        columns: ['role', 'is_active'],
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );
      if (adminCount <= 1 &&
          userRows.isNotEmpty &&
          userRows.first['role'] == 'ADMIN' &&
          userRows.first['is_active'] == 1) {
        throw StateError('لا يمكن تعطيل آخر مدير نشط.');
      }
    }
    await database.update(
      'users',
      {'is_active': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> _upgradeLegacyPassword({
    required Database database,
    required int userId,
    required String password,
  }) async {
    final salt = HashHelper.generateSalt();
    final passwordHash = await HashHelper.hashPassword(password, salt);
    await database.update(
        'users',
        {
          'password_hash': passwordHash,
          'salt': salt,
          'password_algorithm': HashHelper.pbkdf2Sha256V1,
        },
        where: 'id = ?',
        whereArgs: [userId]);
  }

  String _validateUserDetails({
    required String username,
    required String fullName,
    required String password,
  }) {
    final normalizedUsername = username.trim();
    if (normalizedUsername.isEmpty) {
      throw const FormatException('اسم المستخدم مطلوب.');
    }
    if (fullName.trim().isEmpty) {
      throw const FormatException('الاسم الكامل مطلوب.');
    }
    if (!HashHelper.isValidNewPassword(password)) {
      throw FormatException(HashHelper.newPasswordValidationMessage());
    }
    return normalizedUsername;
  }

  void _validateSchoolProfile(SchoolProfileModel profile) {
    if (profile.schoolName.trim().isEmpty ||
        profile.governorate.trim().isEmpty ||
        profile.directorName.trim().isEmpty ||
        profile.secretaryName.trim().isEmpty) {
      throw const FormatException('يرجى إدخال جميع معلومات المدرسة.');
    }
  }

  Future<bool> _transactionHasOnlyLegacyDefaultUsers(
    Transaction transaction,
  ) async {
    final countRows =
        await transaction.rawQuery('SELECT COUNT(*) AS count FROM users');
    final count = (countRows.first['count'] as int?) ?? 0;
    final legacyRows = await transaction.rawQuery('''
      SELECT COUNT(*) AS count
      FROM users
      WHERE password_algorithm = ?
        AND ((username = ? AND full_name = ?)
          OR (username = ? AND full_name = ?))
    ''', [
      HashHelper.legacySha256,
      'admin',
      'مدير المدرسة',
      'secretary',
      'أمين السر',
    ]);
    final legacyCount = (legacyRows.first['count'] as int?) ?? 0;
    return count > 0 && count == legacyCount;
  }
}
