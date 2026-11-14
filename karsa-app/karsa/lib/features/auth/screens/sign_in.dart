// lib/features/auth/screens/sign_in.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:karsa/core/constants/app_colors.dart';
import 'package:karsa/core/constants/app_text_style.dart';
import 'package:karsa/core/providers/auth_provider.dart';
import 'package:karsa/features/auth/screens/sign_up_screen.dart';
import 'package:karsa/shared/widgets/main_shell.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authProvider.notifier)
        .login(
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (!mounted) return;

    if (success) {
      ref.read(mainTabProvider.notifier).state = 0;
      // Navigasi ke MainShell, hapus semua history
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (_) => false,
      );
    } else {
      // Error sudah ada di state, akan di-render di UI
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final errorMessage = authState.error;

    return Scaffold(
      // ✅ Pakai AppColor.brand (Layer 2 token) bukan AppColor.primary500
      backgroundColor: AppColor.brand,
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // ══════════════════════════════════════════
            // 1. HEADER HIJAU
            // ══════════════════════════════════════════
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 60.0, 24.0, 14.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(30),
                      Text(
                        'Hai!',
                        style: AppTextStyle.display3Semibold.copyWith(
                          // ✅ Pakai AppColor.text100 (Layer 1 — putih untuk di atas hijau)
                          color: AppColor.text100,
                        ),
                      ),
                      Text(
                        'Selamat datang kembali!',
                        style: AppTextStyle.paragraph1Regular.copyWith(
                          color: AppColor.text100,
                        ),
                      ),
                      const Gap(45),
                    ],
                  ),
                ),
              ),
            ),

            // ══════════════════════════════════════════
            // 2. KARTU PUTIH (FORM)
            // ══════════════════════════════════════════
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Masuk',
                        style: AppTextStyle.heading3Semibold.copyWith(
                          color: AppColor.text700,
                        ),
                      ),
                      const Gap(24),

                      // ── Error Banner ─────────────────────────
                      if (errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.danger100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            errorMessage,
                            style: AppTextStyle.paragraph2Medium.copyWith(
                              color: AppColor.danger500,
                            ),
                          ),
                        ),
                        const Gap(16),
                      ],

                      // ── Input Email ──────────────────────────
                      Text(
                        'Email',
                        style: AppTextStyle.paragraph2Medium.copyWith(
                          color: AppColor.text700,
                        ),
                      ),
                      const Gap(8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        enabled: !isLoading,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Eh, ada yang kelewatan nih — email dulu ya.';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'contoh@email.com',
                          hintStyle: AppTextStyle.paragraph2Medium.copyWith(
                            color: AppColor.textDisabled,
                          ),
                          filled: true,
                          fillColor: AppColor.background200,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColor.danger500,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const Gap(16),

                      // ── Input Password ───────────────────────
                      Text(
                        'Password',
                        style: AppTextStyle.paragraph2Medium.copyWith(
                          color: AppColor.text700,
                        ),
                      ),
                      const Gap(8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleLogin(),
                        enabled: !isLoading,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Eh, ada yang kelewatan nih — password dulu ya.';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Password kamu',
                          hintStyle: AppTextStyle.paragraph2Medium.copyWith(
                            color: AppColor.textDisabled,
                          ),
                          filled: true,
                          fillColor: AppColor.background200,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColor.danger500,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColor.textDisabled,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                      ),
                      const Gap(8),

                      // ── Lupa Password (non-functional MVP) ──
                      TextButton(
                        onPressed: null, // non-functional di MVP
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Lupa Password?',
                          style: AppTextStyle.paragraph2Medium.copyWith(
                            color: AppColor.info500,
                          ),
                        ),
                      ),
                      const Gap(32),

                      // ── CTA Masuk ────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            // ✅ Pakai AppColor.brandDark untuk pressed state
                            backgroundColor: AppColor.brand,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColor.brand.withValues(
                              alpha: 0.6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Masuk',
                                  style: AppTextStyle.subheading2Semibold
                                      .copyWith(color: Colors.white),
                                ),
                        ),
                      ),
                      const Gap(24),

                      // Social login (Google/Apple) out of scope MVP — PRD 6 & 10

                      // ── Link ke Register ─────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Belum punya akun? ',
                            style: AppTextStyle.paragraph2Medium.copyWith(
                              color: AppColor.textDisabled,
                            ),
                          ),
                          GestureDetector(
                            onTap: isLoading
                                ? null
                                : () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const SignUpScreen(),
                                      ),
                                    );
                                  },
                            child: Text(
                              'Daftar sekarang!',
                              style: AppTextStyle.paragraph2Semibold.copyWith(
                                // ✅ Pakai AppColor.brand (Layer 2)
                                color: AppColor.brand,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(10),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
