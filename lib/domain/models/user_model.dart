enum UserRole { admin, secretary }

extension UserRoleExtension on UserRole {
  String toName() {
    switch (this) {
      case UserRole.admin:
        return 'مدير المدرسة';
      case UserRole.secretary:
        return 'أمين السر';
    }
  }

  static UserRole fromString(String roleStr) {
    if (roleStr.toUpperCase() == 'ADMIN') return UserRole.admin;
    return UserRole.secretary;
  }
}

class UserModel {
  final int id;
  final String username;
  final String fullName;
  final UserRole role;
  final bool isActive;

  UserModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    required this.isActive,
  });
}