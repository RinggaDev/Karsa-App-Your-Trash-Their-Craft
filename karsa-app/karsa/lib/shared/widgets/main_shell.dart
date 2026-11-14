// lib/shared/widgets/main_shell.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karsa/core/constants/app_colors.dart';
import 'package:karsa/core/constants/app_text_style.dart';
import 'package:karsa/features/home/screens/home.dart';
import 'package:karsa/features/profile/screens/profile_screen.dart';
import 'package:karsa/features/riwayat/screens/riwayat_screen.dart';
import 'package:karsa/features/wawasan/screens/wawasan_screen.dart';
import 'package:karsa/shared/widgets/karsa_bottom_nav.dart';

/// Provider untuk menyimpan index tab aktif di MainShell:
/// 0 = Beranda, 1 = Riwayat, 2 = Wawasan, 3 = Profil
final mainTabProvider = StateProvider<int>((ref) => 0);

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  DateTime? _lastBackPressed;

  static const List<Widget> _screens = [
    HomeScreen(),
    RiwayatScreen(),
    WawasanScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialIndex != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(mainTabProvider.notifier).state = widget.initialIndex;
        }
      });
    }
  }

  void _handlePopInvoked(bool didPop, int currentIndex) {
    if (didPop) return;

    // Jika sedang bukan di tab Beranda (0), kembali ke Beranda dulu
    if (currentIndex != 0) {
      ref.read(mainTabProvider.notifier).state = 0;
      return;
    }

    // Jika sudah di tab Beranda, terapkan double-press to exit
    final now = DateTime.now();
    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = now;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Tekan sekali lagi buat keluar dari Karsa ya! 👋',
              style: AppTextStyle.paragraph2Medium.copyWith(
                color: AppColor.textOnBrand,
              ),
            ),
            backgroundColor: AppColor.brandDark,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      return;
    }

    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(mainTabProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) =>
          _handlePopInvoked(didPop, currentIndex),
      child: Scaffold(
        backgroundColor: AppColor.background,
        body: IndexedStack(
          index: currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: KarsaBottomNav(
          currentIndex: currentIndex,
          onTap: (index) {
            if (currentIndex != index) {
              ref.read(mainTabProvider.notifier).state = index;
            }
          },
        ),
      ),
    );
  }
}

