import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../core/security/hash_helper.dart';
import '../../../../database/database_helper.dart';
import '../models/auth_user_model.dart';

class AuthRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<void> ensureDefaultUsers() async {
    final database = await _databaseHelper.database;
    final countRows =
        await database.rawQuery('SELECT COUNT(*) AS count FROM users');
    final count = (countRows.first['count'] as int?) ?? 0;
    if (count > 0) return;

    await database.transaction((transaction) async {
      await _insertUser(
        transaction,
        username: 'admin',
        fullName: 'مدير المدرسة',
        password: 'admin123',
        role: 'ADMIN',
      );
      await _insertUser(
        transaction,
        username: 'secretary',
        fullName: 'أمين السر',
        password: 'secretary123',
        role: 'SECRETARY',
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
      ],
      where: 'username = ? AND is_active = 1',
      whereArgs: [username.trim()],
      limit: 1,
    );
    if (rows.isEmpty) return null;

    final user = rows.first;
    final hash = HashHelper.hashPassword(
      password,
      user['salt'] as String,
    );
    if (hash != user['password_hash']) return null;
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
    final normalizedUsername = username.trim();
    if (normalizedUsername.isEmpty || password.length < 8) {
      throw const FormatException(
        'اسم المستخدم مطلوب وكلمة المرور يجب أن تكون 8 محارف على الأقل.',
      );
    }
    if (fullName.trim().isEmpty) {
      throw const FormatException('الاسم الكامل مطلوب.');
    }
    final database = await _databaseHelper.database;
    final salt = HashHelper.generateSalt();
    await database.insert('users', {
      'username': normalizedUsername,
      'full_name': fullName.trim(),
      'password_hash': HashHelper.hashPassword(password, salt),
      'salt': salt,
      'role': role,
      'is_active': 1,
    });
  }

  Future<void> changePassword({
    required String username,
    required String currentPassword,
    required String newPassword,
  }) async {
    if (newPassword.length < 8) {
      throw const FormatException(
          'كلمة المرور الجديدة يجب أن تكون 8 محارف على الأقل.');
    }
    final database = await _databaseHelper.database;
    final rows = await database.query(
      'users',
      columns: ['id', 'password_hash', 'salt'],
      where: 'username = ? AND is_active = 1',
      whereArgs: [username],
      limit: 1,
    );
    if (rows.isEmpty) throw const FormatException('المستخدم غير موجود.');

    final user = rows.first;
    final currentHash = HashHelper.hashPassword(
      currentPassword,
      user['salt'] as String,
    );
    if (currentHash != user['password_hash']) {
      throw const FormatException('كلمة المرور الحالية غير صحيحة.');
    }

    final salt = HashHelper.generateSalt();
    await database.update(
      'users',
      {
        'password_hash': HashHelper.hashPassword(newPassword, salt),
        'salt': salt,
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

  Future<void> _insertUser(
    Transaction transaction, {
    required String username,
    required String fullName,
    required String password,
    required String role,
  }) async {
    final salt = HashHelper.generateSalt();
    await transaction.insert('users', {
      'username': username,
      'full_name': fullName,
      'password_hash': HashHelper.hashPassword(password, salt),
      'salt': salt,
      'role': role,
      'is_active': 1,
    });
  }
}
