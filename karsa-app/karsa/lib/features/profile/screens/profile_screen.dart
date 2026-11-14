// lib/features/profile/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:karsa/core/constants/app_colors.dart';
import 'package:karsa/core/constants/app_text_style.dart';
import 'package:karsa/core/providers/auth_provider.dart';
import 'package:karsa/features/auth/screens/sign_in.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Pastikan data profil tersinkronisasi jika email/kota belum lengkap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = ref.read(currentUserProvider);
      if (user == null || user.email.isEmpty || user.kota.isEmpty) {
        ref.read(authProvider.notifier).fetchProfile();
      }
    });
  }

  String _getInitial(String? nama) {
    final trimmed = (nama ?? '').trim();
    if (trimmed.isEmpty) return 'K';
    return trimmed[0].toUpperCase();
  }

  void _showEditProfileSheet(BuildContext context, UserModel? user) {
    final namaCtrl = TextEditingController(text: user?.nama ?? '');
    final kotaCtrl = TextEditingController(text: user?.kota ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColor.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return Consumer(
          builder: (context, ref, _) {
            final isLoading = ref.watch(authLoadingProvider);
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lengkapi Profilmu',
                      style: AppTextStyle.subheading1Semibold.copyWith(
                        color: AppColor.textPrimary,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      'Biar UMKM lokal makin gampang kenalan sama kamu.',
                      style: AppTextStyle.paragraph2Regular.copyWith(
                        color: AppColor.textSecondary,
                      ),
                    ),
                    const Gap(20),
                    Text(
                      'Nama Panggilan',
                      style: AppTextStyle.paragraph2Medium.copyWith(
                        color: AppColor.text700,
                      ),
                    ),
                    const Gap(8),
                    TextFormField(
                      controller: namaCtrl,
                      textCapitalization: TextCapitalization.words,
                      enabled: !isLoading,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Yuk isi namamu dulu ya.'
                          : null,
                      decoration: InputDecoration(
                        hintText: 'Nama kamu',
                        filled: true,
                        fillColor: AppColor.background200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const Gap(16),
                    Text(
                      'Kota Domisili',
                      style: AppTextStyle.paragraph2Medium.copyWith(
                        color: AppColor.text700,
                      ),
                    ),
                    const Gap(8),
                    TextFormField(
                      controller: kotaCtrl,
                      textCapitalization: TextCapitalization.words,
                      enabled: !isLoading,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Kota domisilimu belum diisi nih.'
                          : null,
                      decoration: InputDecoration(
                        hintText: 'Contoh: Bandung, Jakarta',
                        filled: true,
                        fillColor: AppColor.background200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const Gap(24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                final ok = await ref
                                    .read(authProvider.notifier)
                                    .updateProfile(
                                      nama: namaCtrl.text.trim(),
                                      kota: kotaCtrl.text.trim(),
                                    );
                                if (ok && sheetCtx.mounted) {
                                  Navigator.of(sheetCtx).pop();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.brand,
                          foregroundColor: AppColor.textOnBrand,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColor.textOnBrand,
                                ),
                              )
                            : Text(
                                'Simpan Profil',
                                style: AppTextStyle.paragraph1Semibold.copyWith(
                                  color: AppColor.textOnBrand,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColor.surfaceWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Text(
          'Yakin mau keluar?',
          style: AppTextStyle.subheading1Semibold.copyWith(
            color: AppColor.textPrimary,
          ),
        ),
        content: Text(
          'Yakin mau keluar? Yuk datang lagi nanti! Kamu bisa masuk lagi kapan aja kok. 👋',
          style: AppTextStyle.paragraph2Regular.copyWith(
            color: AppColor.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              'Batal',
              style: AppTextStyle.paragraph2Medium.copyWith(
                color: AppColor.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await ref.read(authProvider.notifier).logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.danger,
              foregroundColor: AppColor.textOnBrand,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Ya, Keluar',
              style: AppTextStyle.paragraph2Semibold.copyWith(
                color: AppColor.textOnBrand,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final nama = (user?.nama != null && user!.nama.trim().isNotEmpty)
        ? user.nama.trim()
        : 'Teman Karsa';
    final email = (user?.email != null && user!.email.trim().isNotEmpty)
        ? user.email.trim()
        : 'Belum tersedia';
    final kota = (user?.kota != null && user!.kota.trim().isNotEmpty)
        ? user.kota.trim()
        : '';
    final isProfileIncomplete =
        user == null || user.nama.trim().isEmpty || kota.isEmpty;

    return ColoredBox(
      color: AppColor.background,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Top Greeting Bar ──
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Hai, $nama! 👋',
                  style: AppTextStyle.subheading1Semibold.copyWith(
                    color: AppColor.textPrimary,
                  ),
                ),
              ),
              const Gap(28),

              // ══════════════════════════════════════════════════
              // 1. HEADER SECTION (Avatar + Nama + Email)
              // ══════════════════════════════════════════════════
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColor.brand,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColor.surfaceAlt,
                    width: 4,
                  ),
                ),
                child: Center(
                  child: Text(
                    _getInitial(user?.nama),
                    style: AppTextStyle.heading1Bold.copyWith(
                      color: AppColor.textOnBrand,
                    ),
                  ),
                ),
              ),
              const Gap(16),
              Text(
                nama,
                textAlign: TextAlign.center,
                style: AppTextStyle.heading4Bold.copyWith(
                  color: AppColor.textPrimary,
                ),
              ),
              const Gap(4),
              Text(
                email,
                textAlign: TextAlign.center,
                style: AppTextStyle.paragraph2Regular.copyWith(
                  color: AppColor.textSecondary,
                ),
              ),
              const Gap(28),

              // ── Banner Lengkapi Profil (Jika Nama / Kota belum lengkap) ──
              if (isProfileIncomplete) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColor.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColor.surfaceAlt),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profilmu belum lengkap nih',
                              style: AppTextStyle.paragraph2Semibold.copyWith(
                                color: AppColor.brandDark,
                              ),
                            ),
                            const Gap(2),
                            Text(
                              'Yuk lengkapi nama dan kota domisilimu!',
                              style: AppTextStyle.label1Regular.copyWith(
                                color: AppColor.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(12),
                      ElevatedButton(
                        onPressed: () => _showEditProfileSheet(context, user),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.brand,
                          foregroundColor: AppColor.textOnBrand,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Lengkapi Profil',
                          style: AppTextStyle.label1Semibold.copyWith(
                            color: AppColor.textOnBrand,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(20),
              ],

              // ══════════════════════════════════════════════════
              // 2. INFO CARD SECTION (Kota Domisili & Email)
              // ══════════════════════════════════════════════════
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColor.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColor.cardBorder),
                ),
                child: Column(
                  children: [
                    // Baris 1: Kota Domisili
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColor.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedLocation01,
                              color: AppColor.brand,
                              size: 20,
                            ),
                          ),
                        ),
                        const Gap(14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kota Domisili',
                                style: AppTextStyle.label1Regular.copyWith(
                                  color: AppColor.textSecondary,
                                ),
                              ),
                              const Gap(2),
                              Text(
                                kota.isNotEmpty ? kota : 'Belum diatur',
                                style: AppTextStyle.paragraph1Semibold.copyWith(
                                  color: AppColor.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => _showEditProfileSheet(context, user),
                          child: Text(
                            'Ubah',
                            style: AppTextStyle.label1Semibold.copyWith(
                              color: AppColor.brand,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(color: AppColor.divider, height: 1),
                    ),

                    // Baris 2: Email
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColor.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedMail01,
                              color: AppColor.brand,
                              size: 20,
                            ),
                          ),
                        ),
                        const Gap(14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Email',
                                style: AppTextStyle.label1Regular.copyWith(
                                  color: AppColor.textSecondary,
                                ),
                              ),
                              const Gap(2),
                              Text(
                                email,
                                style: AppTextStyle.paragraph1Semibold.copyWith(
                                  color: AppColor.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(28),

              // ══════════════════════════════════════════════════
              // 3. ACTION SECTION (Tombol Keluar)
              // ══════════════════════════════════════════════════
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => _showLogoutDialog(context, ref),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColor.danger,
                    side: BorderSide(
                      color: AppColor.danger.withValues(alpha: 0.45),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedLogout01,
                        color: AppColor.danger,
                        size: 20,
                      ),
                      const Gap(8),
                      Text(
                        'Keluar',
                        style: AppTextStyle.paragraph1Semibold.copyWith(
                          color: AppColor.danger,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(36),

              // ══════════════════════════════════════════════════
              // 4. FOOTER
              // ══════════════════════════════════════════════════
              Text(
                'Karsa v1.0 · Sampahmu, Karya Mereka 🌱',
                textAlign: TextAlign.center,
                style: AppTextStyle.label1Regular.copyWith(
                  color: AppColor.textDisabled,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

