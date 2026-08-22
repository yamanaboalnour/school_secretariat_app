import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../core/security/hash_helper.dart';
import '../../../../database/database_helper.dart';
import '../models/auth_user_model.dart';

class AuthRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<void> ensureDefaultUsers() async {
    final database = await _databaseHelper.database;
    final countRows = await database.rawQuery('SELECT COUNT(*) AS count FROM users');
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
      columns: ['id', 'username', 'full_name', 'role'],
      where: 'username = ? AND is_active = 1',
      whereArgs: [username],
      limit: 1,
    );
    return rows.isEmpty ? null : AuthUserModel.fromMap(rows.first);
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
