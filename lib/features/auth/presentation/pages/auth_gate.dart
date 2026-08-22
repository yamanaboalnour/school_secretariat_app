import 'package:flutter/material.dart';

import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../data/auth_service.dart';
import '../../../../presentation/auth/screens/login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _authService = AuthService();
  Future<bool>? _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _initialize();
  }

  Future<bool> _initialize() async {
    await _authService.initialize();
    return (await _authService.currentUser()) != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _initialization,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data! ? const DashboardPage() : const LoginScreen();
      },
    );
  }
}
