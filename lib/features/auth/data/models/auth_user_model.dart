class AuthUserModel {
  final int id;
  final String username;
  final String fullName;
  final String role;
  final bool isActive;

  const AuthUserModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    required this.isActive,
  });

  factory AuthUserModel.fromMap(Map<String, dynamic> map) {
    return AuthUserModel(
      id: map['id'] as int,
      username: map['username'] as String,
      fullName: map['full_name'] as String,
      role: map['role'] as String,
      isActive: (map['is_active'] as int? ?? 1) == 1,
    );
  }
}
