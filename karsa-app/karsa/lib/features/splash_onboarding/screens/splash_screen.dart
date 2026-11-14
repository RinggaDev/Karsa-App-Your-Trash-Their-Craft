// lib/features/splash_onboarding/screens/splash_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:karsa/core/constants/app_colors.dart';
import 'package:karsa/main.dart';

class SplashScreenKarsa extends StatefulWidget {
  const SplashScreenKarsa({super.key});

  @override
  State<SplashScreenKarsa> createState() => _SplashScreenKarsaState();
}

class _SplashScreenKarsaState extends State<SplashScreenKarsa> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthGate()),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.brand,
      body: Center(
        child: Text(
          'Karsa',
          style: TextStyle(
            fontFamily: 'Satoshi',
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [AppColor.primary100, AppColor.primary200],
              ).createShader(const Rect.fromLTWH(0, 0, 300, 70)),
            fontWeight: FontWeight.w700,
            fontSize: 42,
          ),
        ),
      ),
    );
  }
}
