// lib/features/wawasan/screens/wawasan_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:karsa/core/constants/app_colors.dart';
import 'package:karsa/core/constants/app_text_style.dart';
import 'package:karsa/core/providers/home_provider.dart';
import 'package:karsa/core/providers/wawasan_provider.dart';

class WawasanScreen extends ConsumerWidget {
  const WawasanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(wawasanProvider);

    return ColoredBox(
      color: AppColor.background100,
      child: SafeArea(
        child: RefreshIndicator(
          color: AppColor.brand,
          onRefresh: () => ref.read(wawasanProvider.notifier).refresh(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            children: [
              // ── Header Title & Subtitle ──
              Text(
                'Wawasan Dampakmu',
                style: AppTextStyle.subheading1Semibold.copyWith(
                  color: AppColor.textPrimary,
                ),
              ),
              const Gap(6),
              Text(
                'Ringkasan perjalanan kontribusi keren kamu bareng Karsa sejauh ini.',
                style: AppTextStyle.paragraph2Regular.copyWith(
                  color: AppColor.textSecondary,
                ),
              ),
              const Gap(20),

              // ══════════════════════════════════════════════════
              // 4 SECTIONS CONTENT
              // ══════════════════════════════════════════════════
              async.when(
                loading: () => const _WawasanLoadingView(),
                error: (_, _) => _WawasanBody(
                  stats: const UserStats(
                    totalKg: 0,
                    totalSubmissions: 0,
                    totalActive: 0,
                    totalUmkmHelped: 0,
                    co2Saved: 0,
                  ),
                  insightChild: _InsightFallbackContent(
                    onRetry: () => ref.read(wawasanProvider.notifier).refresh(),
                  ),
                ),
                data: (data) => _WawasanBody(
                  stats: data.stats,
                  insightChild: _buildInsightBody(ref, data),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightBody(WidgetRef ref, MacroInsightData data) {
    if (data.hasInsightError) {
      return _InsightFallbackContent(
        onRetry: () => ref.read(wawasanProvider.notifier).refresh(),
      );
    }
    if (data.isEmpty) {
      return Text(
        kMacroEmpty,
        style: AppTextStyle.paragraph2Regular.copyWith(
          color: AppColor.textSecondary,
          height: 1.5,
        ),
      );
    }
    return Text(
      data.insight ?? kMacroFallback,
      style: AppTextStyle.paragraph1Regular.copyWith(
        color: AppColor.text700,
        height: 1.5,
      ),
    );
  }
}

class _WawasanBody extends StatelessWidget {
  const _WawasanBody({
    required this.stats,
    required this.insightChild,
  });

  final UserStats stats;
  final Widget insightChild;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ══════════════════════════════════════════════════════════
        // SECTION 1: PERTUMBUHAN KONTRIBUSI (Growth - Light Green Gradient)
        // ══════════════════════════════════════════════════════════
        _GrowthSectionCard(totalKg: stats.totalKg),
        const Gap(24),

        // ══════════════════════════════════════════════════════════
        // SECTION 2: DAMPAK SOSIAL (Community - White Cards + Soft Shadow)
        // ══════════════════════════════════════════════════════════
        _CommunitySection(
          totalSubmissions: stats.totalSubmissions,
          totalUmkmHelped: stats.totalUmkmHelped,
        ),
        const Gap(24),

        // ══════════════════════════════════════════════════════════
        // SECTION 3: DAMPAK LINGKUNGAN (Nature - Dark Green & Earth Tone)
        // ══════════════════════════════════════════════════════════
        _NatureSectionCard(co2Saved: stats.co2Saved),
        const Gap(24),

        // ══════════════════════════════════════════════════════════
        // SECTION 4: CATATAN AI (Insight)
        // ══════════════════════════════════════════════════════════
        _AiInsightContainer(child: insightChild),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// SECTION 1: PERTUMBUHAN KONTRIBUSI (Card Gradient Hijau Muda)
// ══════════════════════════════════════════════════════════════════
class _GrowthSectionCard extends StatelessWidget {
  const _GrowthSectionCard({required this.totalKg});
  final double totalKg;

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
        // boxShadow: [
        //   BoxShadow(
        //     color: AppColor.brand.withValues(alpha: 0.10),
        //     blurRadius: 16,
        //     offset: const Offset(0, 6),
        //   ),
        // ],
      ),
      // 1. Tambahkan ClipRRect agar sudut SVG terpotong rapi sesuai radius
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19), // 19 karena ada border 1px
        // 2. Gunakan Stack untuk menumpuk SVG di belakang konten
        child: Stack(
          children: [
            // Background SVG Overlay
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/images/components/overlay_summary_screen.svg',
                fit: BoxFit.fill,
              ),
            ),

            // 3. Konten Asli (dibungkus Padding)
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Sampah didaur ulang',
                            style: AppTextStyle.paragraph2Medium.copyWith(
                              color: AppColor.brand,
                            ),
                          ),
                        ],
                      ),
                      // Pill Pertumbuhan di sebelah header/angka (Masih di-comment sesuai aslinya)
                      // Container(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 10,
                      //     vertical: 5,
                      //   ),
                      //   decoration: BoxDecoration(
                      //     color: AppColor.surfaceWhite.withValues(alpha: 0.88),
                      //     borderRadius: BorderRadius.circular(20),
                      //     border: Border.all(
                      //       color: AppColor.brand.withValues(alpha: 0.25),
                      //     ),
                      //   ),
                      //   child: Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       const HugeIcon(
                      //         icon: HugeIcons.strokeRoundedTrendingUp,
                      //         color: AppColor.brand,
                      //         size: 14,
                      //       ),
                      //       const Gap(4),
                      //       Text(
                      //         growthBadgeText,
                      //         style: AppTextStyle.label2Bold.copyWith(
                      //           color: AppColor.brandDark,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        totalKg.toStringAsFixed(1),
                        style: AppTextStyle.display2Bold.copyWith(
                          color: AppColor.text700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'kg',
                        style: AppTextStyle.heading4Semibold.copyWith(
                          color: AppColor.brand.withValues(alpha: 0.24),
                        ),
                      ),
                    ],
                  ),
                  const Gap(8),
                  Text(
                    'Sampah terpilahmu yang udah berhasil disulap jadi bahan baku karya baru.',
                    style: AppTextStyle.label1Medium.copyWith(
                      color: AppColor.brand.withValues(alpha: 0.55),
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
// SECTION 2: DAMPAK SOSIAL ("Kontribusi Sesama" - Simpel 2 Kolom)
// ══════════════════════════════════════════════════════════════════
class _CommunitySection extends StatelessWidget {
  const _CommunitySection({
    required this.totalSubmissions,
    required this.totalUmkmHelped,
  });

  final int totalSubmissions;
  final int totalUmkmHelped;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kontribusi Sesama',
          style: AppTextStyle.subheading2Semibold.copyWith(
            color: AppColor.textPrimary,
          ),
        ),
        const Gap(4),
        Text(
          'Jejak kolaborasi kamu bareng pengrajin dan mitra UMKM lokal.',
          style: AppTextStyle.label1Regular.copyWith(
            color: AppColor.text300,
          ),
        ),
        const Gap(12),
        Row(
          children: [
            Expanded(
              child: _CommunityMetricCard(
                iconWidget: const HugeIcon(
                  icon: HugeIcons.strokeRoundedDeliveryTruck02,
                  color: AppColor.brand,
                  size: 22,
                ),
                unit: 'Kali',
                value: '$totalSubmissions',
                label: 'Total Kontribusi',
              ),
            ),
            const Gap(12),
            Expanded(
              child: _CommunityMetricCard(
                iconWidget: const HugeIcon(
                  icon: HugeIcons.strokeRoundedStore01,
                  color: AppColor.brand,
                  size: 22,
                ),
                unit: 'Mitra',
                value: '$totalUmkmHelped',
                label: 'UMKM Terbantu',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CommunityMetricCard extends StatelessWidget {
  const _CommunityMetricCard({
    required this.iconWidget,
    required this.value,
    required this.unit,
    required this.label,
  });

  final Widget iconWidget;
  final String value;
  final String unit;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.background300,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          iconWidget,
          const Gap(18),
          Row(
            children: [
              Text(
                value,
                style: AppTextStyle.heading4Semibold.copyWith(
                  color: AppColor.text700,
                ),
              ),
              Gap(3),
              Text(
                unit,
                style: AppTextStyle.paragraph2Medium.copyWith(
                  color: AppColor.text300,
                ),
              ),
            ],
          ),

          const Gap(4),
          Text(
            label,
            style: AppTextStyle.label1Regular.copyWith(
              color: AppColor.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// SECTION 3: DAMPAK LINGKUNGAN ("Bumi Sedang Bernapas" - Simpel 2 Kolom)
// ══════════════════════════════════════════════════════════════════
class _NatureSectionCard extends StatelessWidget {
  const _NatureSectionCard({required this.co2Saved});
  final double co2Saved;

  @override
  Widget build(BuildContext context) {
    // Rumus: 1 pohon menyerap ~21 kg CO2/tahun
    final double treesCount = co2Saved / 21.0;
    final String treesFormatted = co2Saved <= 0
        ? '0'
        : (treesCount >= 10
              ? treesCount.toStringAsFixed(0)
              : treesCount.toStringAsFixed(1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bumi Sedang Bernapas',
          style: AppTextStyle.subheading2Semibold.copyWith(
            color: AppColor.textPrimary,
          ),
        ),
        const Gap(4),
        Text(
          'Dampak nyata dari setiap kilogram sampah yang gak berakhir di TPA.',
          style: AppTextStyle.label1Regular.copyWith(
            color: AppColor.text300,
          ),
        ),
        const Gap(12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _NatureMetricCard(
                  iconWidget: const Icon(
                    Icons.cloud_outlined,
                    color: AppColor.brand,
                    size: 20,
                  ),
                  value: co2Saved.toStringAsFixed(1),
                  unit: 'kg',
                  label: 'Emisi CO₂, berkurang',
                ),
              ),
              const Gap(12),
              Expanded(
                child: _NatureMetricCard(
                  iconWidget: const Icon(
                    Icons.park_outlined,
                    color: AppColor.brand,
                    size: 20,
                  ),
                  value: '~$treesFormatted',
                  label: 'Setara dengan Pohon',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NatureMetricCard extends StatelessWidget {
  const _NatureMetricCard({
    required this.iconWidget,
    required this.value,
    required this.label,
    this.unit,
  });

  final Widget iconWidget;
  final String value;
  final String? unit;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColor.background300,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColor.surface200,
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
                    Text(
                      value,
                      style: AppTextStyle.subheading1Semibold.copyWith(
                        color: AppColor.text700,
                      ),
                    ),
                    if (unit != null) ...[
                      const SizedBox(width: 4),
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
// SECTION 4: CATATAN AI ("Catatan Kontribusi")
// ══════════════════════════════════════════════════════════════════
class _AiInsightContainer extends StatelessWidget {
  const _AiInsightContainer({required this.child});
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
                  'Catatan Kontribusi (Dihasilkan oleh AI)',
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

class _InsightFallbackContent extends StatelessWidget {
  const _InsightFallbackContent({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Insight lagi diproses... Cek lagi sebentar ya!',
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

class _WawasanLoadingView extends StatelessWidget {
  const _WawasanLoadingView();

  @override
  Widget build(BuildContext context) {
    Widget skeletonBox(double height, {double radius = 18}) => Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.skeleton,
        borderRadius: BorderRadius.circular(radius),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section 1 Skeleton
        skeletonBox(152, radius: 20),
        const Gap(24),

        // Section 2 Skeleton
        skeletonBox(20, radius: 6),
        const Gap(12),
        Row(
          children: [
            Expanded(child: skeletonBox(140)),
            const Gap(12),
            Expanded(child: skeletonBox(140)),
          ],
        ),
        const Gap(24),

        // Section 3 Skeleton
        skeletonBox(20, radius: 6),
        const Gap(12),
        skeletonBox(176, radius: 20),
        const Gap(24),

        // Section 4 Skeleton (Catatan AI)
        _AiInsightContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                  Text(
                    'Insight lagi diproses...',
                    style: AppTextStyle.paragraph2Medium.copyWith(
                      color: AppColor.textSecondary,
                    ),
                  ),
                ],
              ),
              const Gap(12),
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColor.surfaceAlt,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const Gap(8),
              Container(
                height: 12,
                width: 200,
                decoration: BoxDecoration(
                  color: AppColor.surfaceAlt,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
