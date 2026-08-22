import '../../../core/security/security_storage.dart';
import 'models/auth_user_model.dart';
import 'repositories/auth_repository.dart';

class AuthService {
  final AuthRepository _repository;
  final SecurityStorage _storage;

  AuthService({AuthRepository? repository, SecurityStorage? storage})
      : _repository = repository ?? AuthRepository(),
        _storage = storage ?? SecurityStorage();

  Future<void> initialize() => _repository.ensureDefaultUsers();

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
}
