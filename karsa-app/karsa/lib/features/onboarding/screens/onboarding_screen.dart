// lib/features/onboarding/screens/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:karsa/core/constants/app_colors.dart';
import 'package:karsa/core/constants/app_text_style.dart';
import 'package:karsa/core/providers/auth_provider.dart';
import 'package:karsa/features/home/screens/home.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaController;
  late final TextEditingController _kotaController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _namaController = TextEditingController(text: user?.nama ?? '');
    _kotaController = TextEditingController(text: user?.kota ?? '');
  }

  @override
  void dispose() {
    _namaController.dispose();
    _kotaController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String hint) => InputDecoration(
        hintText: hint,
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
          borderSide: const BorderSide(color: AppColor.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColor.danger),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authProvider.notifier).updateProfile(
          nama: _namaController.text.trim(),
          kota: _kotaController.text.trim(),
        );
    if (!mounted || !ok) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(50),
                Text(
                  'Sebelum mulai, kenalan dulu yuk!',
                  style: AppTextStyle.heading3Semibold.copyWith(
                    color: AppColor.textPrimary,
                  ),
                ),
                const Gap(8),
                Text(
                  'Ini biar Karsa bisa kasih pengalaman yang lebih personal buat kamu.',
                  style: AppTextStyle.paragraph2Regular.copyWith(
                    color: AppColor.textSecondary,
                  ),
                ),
                const Gap(32),
                if (auth.error != null) ...[
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
                      auth.error!,
                      style: AppTextStyle.paragraph2Medium.copyWith(
                        color: AppColor.danger,
                      ),
                    ),
                  ),
                  const Gap(16),
                ],
                Text(
                  'Nama lengkap',
                  style: AppTextStyle.paragraph2Medium.copyWith(
                    color: AppColor.textPrimary,
                  ),
                ),
                const Gap(8),
                TextFormField(
                  controller: _namaController,
                  enabled: !auth.isLoading,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration('Nama kamu'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Siapa namamu? Yuk isi dulu ya.'
                      : null,
                ),
                const Gap(16),
                Text(
                  'Kota domisili',
                  style: AppTextStyle.paragraph2Medium.copyWith(
                    color: AppColor.textPrimary,
                  ),
                ),
                const Gap(8),
                TextFormField(
                  controller: _kotaController,
                  enabled: !auth.isLoading,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: _decoration('Misal: Jakarta, Bandung'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Kota kamu di mana? Isi dulu ya.'
                      : null,
                ),
                const Gap(32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.brand,
                      foregroundColor: AppColor.textOnBrand,
                      disabledBackgroundColor:
                          AppColor.brand.withValues(alpha: 0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: auth.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColor.textOnBrand,
                            ),
                          )
                        : Text(
                            'Mulai Karsa!',
                            style: AppTextStyle.subheading2Semibold.copyWith(
                              color: AppColor.textOnBrand,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

