// lib/features/summary/screens/summary_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:karsa/core/constants/app_colors.dart';
import 'package:karsa/core/constants/app_text_style.dart';
import 'package:karsa/core/providers/input_provider.dart';
import 'package:karsa/core/providers/status_provider.dart';
import 'package:karsa/core/providers/summary_provider.dart';
import 'package:karsa/features/home/widgets/CTA_button.dart';
import 'package:karsa/features/submission/screens/input_screen.dart';
import 'package:karsa/shared/widgets/main_shell.dart';

String _formatRupiah(int value) {
  final str = value.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(str[i]);
  }
  return buffer.toString();
}

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key, required this.submissionId});

  final String submissionId;

  void _goHome(BuildContext context, WidgetRef ref) {
    ref.read(mainTabProvider.notifier).state = 0;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (_) => false,
    );
  }

  void _grabAgain(BuildContext context, WidgetRef ref) {
    ref.read(inputProvider.notifier).reset();
    ref.read(mainTabProvider.notifier).state = 0;
    final nav = Navigator.of(context);
    nav.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (_) => false,
    );
    nav.push(MaterialPageRoute(builder: (_) => const InputScreen()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightAsync = ref.watch(summaryProvider(submissionId));
    final subAsync = ref.watch(submissionNotifierProvider(submissionId));

    final subData = subAsync.valueOrNull;
    final beratKg = (subData?['berat_kg'] as num?)?.toDouble() ?? 0.0;
    final co2Saved = beratKg * 1.5;
    final estimasiRupiah = (beratKg * 10000).round();

    return Scaffold(
      backgroundColor: AppColor.background100,
      appBar: AppBar(
        backgroundColor: AppColor.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft02,
            color: AppColor.textPrimary,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Insight Sesi Ini',
          style: AppTextStyle.subheading1Semibold.copyWith(
            color: AppColor.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ══════════════════════════════════════════════════
                    // 1. HERO CONTAINER (Overlay SVG + Kg dikirim & UMKM terbantu)
                    // ══════════════════════════════════════════════════
                    _SummaryHeroCard(beratKg: beratKg),
                    const Gap(24),

                    // ══════════════════════════════════════════════════
                    // 2. DAMPAK DARI KONTRIBUSIMU (Simpel 2 Kolom: CO2 & Penghasilan UMKM)
                    // ══════════════════════════════════════════════════
                    Text(
                      'Dampak dari kontribusimu',
                      style: AppTextStyle.subheading2Semibold.copyWith(
                        color: AppColor.textPrimary,
                      ),
                    ),
                    const Gap(12),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _SimpleImpactCard(
                              iconBgColor: AppColor.surface200,
                              iconWidget: const HugeIcon(
                                icon: HugeIcons.strokeRoundedLeaf02,
                                color: AppColor.brand,
                                size: 20,
                              ),
                              value: '~${co2Saved.toStringAsFixed(1)}',
                              unit: 'kg',
                              label: 'Estimasi pengurangan CO₂',
                            ),
                          ),
                          const Gap(12),
                          Expanded(
                            child: _SimpleImpactCard(
                              iconBgColor: const Color(0xFFFEF3DC),
                              iconWidget: const Icon(
                                Icons.monetization_on_outlined,
                                color: Color(0xFFD88B00),
                                size: 20,
                              ),
                              value: '~Rp ${_formatRupiah(estimasiRupiah)}',
                              label: 'Mendukung penghasilan UMKM',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(24),

                    // ══════════════════════════════════════════════════
                    // 3. INSIGHT AI (Dihasilkan oleh AI)
                    // ══════════════════════════════════════════════════
                    _AiMicroInsightContainer(
                      child: insightAsync.when(
                        loading: () => const _InsightLoading(),
                        error: (e, _) => _InsightFallback(
                          message: e is String ? e : kInsightFallback,
                          onRetry: () => ref
                              .read(summaryProvider(submissionId).notifier)
                              .refresh(submissionId),
                        ),
                        data: (insight) => Text(
                          insight,
                          style: AppTextStyle.paragraph1Regular.copyWith(
                            color: AppColor.text700,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ══════════════════════════════════════════════════
            // 4. CTA SECTION (Angkut Lagi & Ke Home)
            // ══════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomCtaButton(
                    label: 'Angkut Lagi!',
                    onTap: () => _grabAgain(context, ref),
                  ),
                  const Gap(6),
                  TextButton(
                    onPressed: () => _goHome(context, ref),
                    child: Text(
                      'Ke Home',
                      style: AppTextStyle.paragraph2Semibold.copyWith(
                        color: AppColor.brand,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// 1. HERO CONTAINER (Seperti di wawasan_screen.dart:L163-L280 + Mockup)
// ══════════════════════════════════════════════════════════════════
class _SummaryHeroCard extends StatelessWidget {
  const _SummaryHeroCard({required this.beratKg});
  final double beratKg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColor.primary400.withValues(alpha: 0.55),
          width: 0.3,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Stack(
          children: [
            // Background SVG Overlay
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/images/components/overlay_summary_screen.svg',
                fit: BoxFit.cover,
              ),
            ),

            // Konten
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Keren, kamu sudah\nberkontribusi! 🎉',
                    style: AppTextStyle.heading4Bold.copyWith(
                      color: AppColor.brandDark,
                      height: 1.25,
                    ),
                  ),
                  const Gap(18),

                  // Box Putih Status: Kg yang dikirim & UMKM terbantu
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.surfaceWhite.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Stat 1: Kg yang dikirim
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  beratKg.toStringAsFixed(1),
                                  style: AppTextStyle.heading4Bold.copyWith(
                                    color: AppColor.text700,
                                  ),
                                ),
                                const Gap(4),
                                Text(
                                  'kg',
                                  style: AppTextStyle.paragraph1Semibold
                                      .copyWith(
                                        color: AppColor.brandDark,
                                      ),
                                ),
                              ],
                            ),
                            const Gap(2),
                            Text(
                              'Kg yang dikirim',
                              style: AppTextStyle.label1Regular.copyWith(
                                color: AppColor.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const Gap(24),
                        Container(
                          width: 1,
                          height: 34,
                          color: AppColor.divider,
                        ),
                        const Gap(24),

                        // Stat 2: UMKM terbantu
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '1',
                              style: AppTextStyle.heading4Bold.copyWith(
                                color: AppColor.text700,
                              ),
                            ),
                            const Gap(2),
                            Text(
                              'UMKM terbantu',
                              style: AppTextStyle.label1Regular.copyWith(
                                color: AppColor.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// 2. CARD SIMPEL DAMPAK (Seperti di wawasan_screen.dart)
// ══════════════════════════════════════════════════════════════════
class _SimpleImpactCard extends StatelessWidget {
  const _SimpleImpactCard({
    required this.iconBgColor,
    required this.iconWidget,
    required this.value,
    required this.label,
    this.unit,
  });

  final Color iconBgColor;
  final Widget iconWidget;
  final String value;
  final String? unit;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColor.background200,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Center(child: iconWidget),
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: AppTextStyle.subheading1Semibold.copyWith(
                          color: AppColor.text700,
                        ),
                      ),
                    ),
                    if (unit != null) ...[
                      const Gap(4),
                      Text(
                        unit!,
                        style: AppTextStyle.paragraph2Regular.copyWith(
                          color: AppColor.text400,
                        ),
                      ),
                    ],
                  ],
                ),
                const Gap(2),
                Text(
                  label,
                  style: AppTextStyle.label1Regular.copyWith(
                    color: AppColor.text700,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// 3. CONTAINER INSIGHT AI (Dihasilkan oleh AI)
// ══════════════════════════════════════════════════════════════════
class _AiMicroInsightContainer extends StatelessWidget {
  const _AiMicroInsightContainer({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColor.surfaceAlt),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColor.brand,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedSparkles,
                    color: AppColor.textOnBrand,
                    size: 18,
                  ),
                ),
              ),
              const Gap(10),
              Expanded(
                child: Text(
                  'Catatan Dampakmu (Dihasilkan oleh AI)',
                  style: AppTextStyle.paragraph2Semibold.copyWith(
                    color: AppColor.brandDark,
                  ),
                ),
              ),
            ],
          ),
          const Gap(16),
          child,
        ],
      ),
    );
  }
}

class _InsightLoading extends StatelessWidget {
  const _InsightLoading();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColor.brand,
          ),
        ),
        const Gap(10),
        Expanded(
          child: Text(
            'Sedang meracik dampakmu...',
            style: AppTextStyle.paragraph2Medium.copyWith(
              color: AppColor.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _InsightFallback extends StatelessWidget {
  const _InsightFallback({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          style: AppTextStyle.paragraph2Medium.copyWith(
            color: AppColor.textSecondary,
          ),
        ),
        const Gap(8),
        TextButton(
          onPressed: onRetry,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(48, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Coba lagi',
            style: AppTextStyle.paragraph2Semibold.copyWith(
              color: AppColor.brand,
            ),
          ),
        ),
      ],
    );
  }
}
