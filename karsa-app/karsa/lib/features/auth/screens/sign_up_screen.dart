// lib/features/auth/screens/sign_up_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:karsa/core/constants/app_colors.dart';
import 'package:karsa/core/constants/app_text_style.dart';
import 'package:karsa/core/providers/auth_provider.dart';
import 'package:karsa/shared/widgets/main_shell.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _kotaController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _kotaController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authProvider.notifier)
        .register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          nama: _namaController.text.trim(),
          kota: _kotaController.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      ref.read(mainTabProvider.notifier).state = 0;
      // Flow A: Setelah berhasil Register -> langsung ke MainShell
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final errorMessage = authState.error;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ══════════════════════════════════════════
          // 4. BOTTOM GRADIENT OVERLAY
          // ══════════════════════════════════════════
          Align(
            alignment: Alignment.bottomCenter,
            child: IgnorePointer(
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.0),
                      const Color(0xFFC8E6C9).withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ══════════════════════════════════════════
          // MAIN FORM CONTENT
          // ══════════════════════════════════════════
          SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Gap(32),

                    // ══════════════════════════════════════════
                    // 1. HEADER SECTION
                    // ══════════════════════════════════════════
                    Text(
                      'Dari Kita Untuk Kita Semua',
                      textAlign: TextAlign.center,
                      style: AppTextStyle.heading2Semibold.copyWith(
                        color: AppColor.text700,
                        height: 1.2,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      'Setiap langkah kecilmu berarti. Yuk mulai perjalanan dampakmu bareng Karsa.',
                      textAlign: TextAlign.center,
                      style: AppTextStyle.paragraph2Regular.copyWith(
                        color: AppColor.textSecondary,
                      ),
                    ),
                    const Gap(32),

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
                      const Gap(20),
                    ],

                    // ══════════════════════════════════════════
                    // 2. FORM SECTION (Nama -> Email -> Kota -> Password)
                    // ══════════════════════════════════════════

                    // ── Field 1: Nama ─────────────────────────
                    Text(
                      'Nama',
                      style: AppTextStyle.paragraph2Medium.copyWith(
                        color: AppColor.text700,
                      ),
                    ),
                    const Gap(8),
                    TextFormField(
                      controller: _namaController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Siapa namamu? Yuk isi dulu ya.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Nama kamu',
                        hintStyle: AppTextStyle.paragraph2Medium.copyWith(
                          color: AppColor.textDisabled,
                        ),
                        filled: true,
                        fillColor: AppColor.background200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColor.brand,
                            width: 1.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColor.danger500,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColor.danger500,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const Gap(16),

                    // ── Field 2: Email ─────────────────────────
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
                        if (v == null || v.trim().isEmpty) {
                          return 'Email dulu ya, biar kita bisa kenalan.';
                        }
                        if (!v.contains('@')) {
                          return 'Format email-nya kurang tepat nih.';
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
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColor.brand,
                            width: 1.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColor.danger500,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColor.danger500,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const Gap(16),

                    // ── Field 3: Kota ─────────────────────────
                    Text(
                      'Kota',
                      style: AppTextStyle.paragraph2Medium.copyWith(
                        color: AppColor.text700,
                      ),
                    ),
                    const Gap(8),
                    TextFormField(
                      controller: _kotaController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Kota kamu di mana? Isi dulu ya.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Misal: Jakarta, Bandung',
                        hintStyle: AppTextStyle.paragraph2Medium.copyWith(
                          color: AppColor.textDisabled,
                        ),
                        filled: true,
                        fillColor: AppColor.background200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColor.brand,
                            width: 1.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColor.danger500,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColor.danger500,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const Gap(16),

                    // ── Field 4: Password ─────────────────────
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
                      onFieldSubmitted: (_) => _handleRegister(),
                      enabled: !isLoading,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Password juga perlu ya!';
                        }
                        if (v.length < 6) {
                          return 'Password minimal 6 karakter ya.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Minimal 6 karakter',
                        hintStyle: AppTextStyle.paragraph2Medium.copyWith(
                          color: AppColor.textDisabled,
                        ),
                        filled: true,
                        fillColor: AppColor.background200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColor.brand,
                            width: 1.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColor.danger500,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColor.danger500,
                            width: 1.5,
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
                    const Gap(16),

                    // ── Link ke Login ─────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sudah punya akun? ',
                          style: AppTextStyle.paragraph2Regular.copyWith(
                            color: AppColor.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: Text(
                            'Login Sekarang',
                            style: AppTextStyle.paragraph2Semibold.copyWith(
                              color: AppColor.brand,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(32),

                    // ══════════════════════════════════════════
                    // 3. FOOTER SECTION
                    // ══════════════════════════════════════════

                    // ── Terms & Disclaimer ───────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Text(
                        'Dengan mendaftar, kamu setuju dengan Ketentuan & Privasi Karsa. Yuk jaga bareng-bareng! 🌱',
                        textAlign: TextAlign.center,
                        style: AppTextStyle.label1Regular.copyWith(
                          color: AppColor.text400,
                          height: 1.4,
                        ),
                      ),
                    ),

                    const Gap(16),

                    // ── CTA Button: Daftar ───────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.brand,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColor.brand.withValues(
                            alpha: 0.6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
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
                                'Daftar',
                                style: AppTextStyle.subheading1Semibold
                                    .copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                      ),
                    ),
                    const Gap(24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
