import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurityStorage {
  static const _currentUsernameKey = 'current_username';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> saveCurrentUsername(String username) {
    return _storage.write(key: _currentUsernameKey, value: username);
  }

  Future<String?> readCurrentUsername() {
    return _storage.read(key: _currentUsernameKey);
  }

  Future<void> clearSession() {
    return _storage.delete(key: _currentUsernameKey);
  }
}
