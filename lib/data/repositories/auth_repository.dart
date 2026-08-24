import 'package:drift/drift.dart';
import '../local/app_database.dart';
import '../../core/security/hash_helper.dart';
import '../../domain/models/user_model.dart';

class AuthRepository {
  final AppDatabase db;

  AuthRepository(this.db);

  /// تسجيل دخول المستخدم والتحقق من كلمة السر
  Future<UserModel?> login(String username, String password) async {
    final query = db.select(db.users)
      ..where((tbl) => tbl.username.equals(username));
    final userRow = await query.getSingleOrNull();

    if (userRow == null || !userRow.isActive) return null;

    final computedHash = await HashHelper.hashPassword(password, userRow.salt);
    if (computedHash == userRow.passwordHash) {
      return UserModel(
        id: userRow.id,
        username: userRow.username,
        fullName: userRow.fullName,
        role: UserRoleExtension.fromString(userRow.role),
        isActive: userRow.isActive,
      );
    }
    return null;
  }

  /// إنشاء حساب جديد (للمدير فقط)
  Future<bool> createUser({
    required String username,
    required String fullName,
    required String password,
    required UserRole role,
  }) async {
    final salt = HashHelper.generateSalt();
    final passwordHash = await HashHelper.hashPassword(password, salt);

    final result = await db.into(db.users).insert(
          UsersCompanion.insert(
            username: username,
            fullName: fullName,
            passwordHash: passwordHash,
            salt: salt,
            role: Value(role == UserRole.admin ? 'ADMIN' : 'SECRETARY'),
          ),
        );
    return result > 0;
  }
}
