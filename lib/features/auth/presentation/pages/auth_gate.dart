import 'package:flutter/material.dart';

import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../data/auth_service.dart';
import '../../../../presentation/auth/screens/login_screen.dart';
import 'initial_setup_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _authService = AuthService();
  Future<_AuthDestination>? _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _initialize();
  }

  Future<_AuthDestination> _initialize() async {
    await _authService.initialize();
    if (await _authService.requiresInitialSetup()) {
      return _AuthDestination.initialSetup;
    }
    return (await _authService.currentUser()) != null
        ? _AuthDestination.dashboard
        : _AuthDestination.login;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AuthDestination>(
      future: _initialization,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        switch (snapshot.data!) {
          case _AuthDestination.initialSetup:
            return const InitialSetupPage();
          case _AuthDestination.dashboard:
            return const DashboardPage();
          case _AuthDestination.login:
            return const LoginScreen();
        }
      },
    );
  }
}

enum _AuthDestination { initialSetup, dashboard, login }
