import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(const Duration(seconds: 5), () {
      _goToLogin();
    });
  }

  void _goToLogin() {
    if (!mounted) return;
    _timer?.cancel();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _goToLogin,
      child: Scaffold(
        backgroundColor: const Color(0xFFC75B02),
        body: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final logoSize = constraints.maxWidth * 0.9;

              return Image.asset(
                'assets/image/logo2remove.png',
                width: logoSize,
                height: logoSize,
                fit: BoxFit.contain,
              );
            },
          ),
        ),
      ),
    );
  }
}
