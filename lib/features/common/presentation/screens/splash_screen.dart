import 'package:flutter/material.dart';

/// Shown while the session/profile is resolving on cold start. The router
/// redirects away as soon as auth state is known.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
