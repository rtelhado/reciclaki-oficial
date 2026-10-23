import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/login_page.dart';

class AcessoProtegido extends StatelessWidget {
  const AcessoProtegido({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (snapshot.hasError) {
        return const Scaffold(
          body: Center(
            child: Text(
              'Não foi possível verificar sua sessão. Reabra o aplicativo.',
            ),
          ),
        );
      }
      return snapshot.data == null ? const LoginPage() : child;
    },
  );
}
