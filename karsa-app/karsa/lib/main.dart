// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karsa/core/constants/app_colors.dart';
import 'package:karsa/core/providers/auth_provider.dart';
import 'package:karsa/features/splash_onboarding/screens/onboarding_1.dart';
import 'package:karsa/features/splash_onboarding/screens/splash_screen.dart';
import 'package:karsa/shared/widgets/main_shell.dart';

void main() {
  runApp(
    // ProviderScope wajib ada di root agar semua Riverpod providers aktif
    const ProviderScope(
      child: KarsaApp(),
    ),
  );
}

class KarsaApp extends StatelessWidget {
  const KarsaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Karsa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColor.brand),
        fontFamily: 'Satoshi',
        useMaterial3: true,
      ),
      // Selalu mulai dari SplashScreenKarsa terlebih dahulu (1.8 detik)
      home: const SplashScreenKarsa(),
    );
  }
}

/// Auth-aware gate yang dijalankan SETELAH SplashScreen selesai.
/// - Jika ada token di secure storage -> langsung HomeScreen (Skip Onboarding & Login).
/// - Jika belum ada token -> Onboarding1 -> Onboarding2 -> Login/SignUp -> HomeScreen.
class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool _checking = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final isAuth = await ref.read(authProvider.notifier).checkAuthStatus();
    if (mounted) {
      setState(() {
        _isAuthenticated = isAuth;
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: AppColor.brand,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    // Flow B: Sudah login -> langsung MainShell
    // Flow A: Belum login -> mulai dari Onboarding1
    return _isAuthenticated ? const MainShell() : const Onboarding1();
  }
}
