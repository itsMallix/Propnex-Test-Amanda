import 'package:flutter/material.dart';
import 'package:propnex_take_home_test/features/auth/presentation/providers/auth_providers.dart';
import 'package:propnex_take_home_test/features/auth/presentation/screens/login_screen.dart';
import 'package:propnex_take_home_test/features/main/presentation/screens/main_screen.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (auth.isLoggedIn) {
          return MainScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
