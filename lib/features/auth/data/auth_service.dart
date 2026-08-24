import '../../../core/security/security_storage.dart';
import '../../settings/data/models/school_profile_model.dart';
import 'models/auth_user_model.dart';
import 'repositories/auth_repository.dart';

class AuthService {
  final AuthRepository _repository;
  final SecurityStorage _storage;

  AuthService({AuthRepository? repository, SecurityStorage? storage})
      : _repository = repository ?? AuthRepository(),
        _storage = storage ?? SecurityStorage();

  Future<void> initialize() async {}

  Future<bool> requiresInitialSetup() => _repository.requiresInitialSetup();

  Future<AuthUserModel?> currentUser() async {
    final username = await _storage.readCurrentUsername();
    if (username == null || username.isEmpty) return null;
    return _repository.findByUsername(username);
  }

  Future<AuthUserModel?> login(String username, String password) async {
    final user = await _repository.login(username, password);
    if (user != null) {
      await _storage.saveCurrentUsername(user.username);
    }
    return user;
  }

  Future<void> logout() => _storage.clearSession();

  Future<AuthUserModel> completeInitialSetup({
    required String username,
    required String fullName,
    required String password,
    required SchoolProfileModel schoolProfile,
  }) async {
    final user = await _repository.completeInitialSetup(
      username: username,
      fullName: fullName,
      password: password,
      schoolProfile: schoolProfile,
    );
    await _storage.saveCurrentUsername(user.username);
    return user;
  }

  Future<List<AuthUserModel>> getUsers() => _repository.getUsers();

  Future<void> createUser({
    required String username,
    required String fullName,
    required String password,
    required String role,
  }) =>
      _repository.createUser(
        username: username,
        fullName: fullName,
        password: password,
        role: role,
      );

  Future<void> changePassword({
    required String username,
    required String currentPassword,
    required String newPassword,
  }) =>
      _repository.changePassword(
        username: username,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

  Future<void> setUserActive(int userId, bool isActive) =>
      _repository.setUserActive(userId, isActive);
}
