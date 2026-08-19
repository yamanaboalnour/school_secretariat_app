import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // معرفة المستخدم الحالي
  User? get currentUser => _auth.currentUser;

  // مجرى حالة تسجيل الدخول
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    await _auth.signOut();
  }
}