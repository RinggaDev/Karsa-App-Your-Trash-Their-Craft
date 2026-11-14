// lib/features/riwayat/screens/riwayat_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:karsa/core/constants/app_colors.dart';
import 'package:karsa/core/constants/app_text_style.dart';
import 'package:karsa/core/providers/input_provider.dart';
import 'package:karsa/core/providers/riwayat_provider.dart';
import 'package:karsa/core/providers/wawasan_provider.dart';
import 'package:karsa/features/home/widgets/CTA_button.dart';
import 'package:karsa/features/submission/screens/input_screen.dart';
import 'package:karsa/features/submission/screens/status_screen.dart';
import 'package:karsa/shared/widgets/main_shell.dart';

enum _FilterTab { semua, aktif, selesai }

const _statusLabels = {
  'pending': 'Menunggu',
  'confirmed': 'Dikonfirmasi',
  'picked_up': 'Dijemput',
  'done': 'Selesai',
};

const _bulanShort = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

String _formatDate(String raw) {
  final d = DateTime.tryParse(raw);
  if (d == null) return raw;
  return '${d.day} ${_bulanShort[d.month - 1]} ${d.year}';
}

class RiwayatScreen extends ConsumerStatefulWidget {
  const RiwayatScreen({super.key});

  @override
  ConsumerState<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends ConsumerState<RiwayatScreen> {
  _FilterTab _selectedTab = _FilterTab.semua;

  List<RecapSubmission> _filter(List<RecapSubmission> all) {
    switch (_selectedTab) {
      case _FilterTab.semua:
        return all;
      case _FilterTab.aktif:
        return all.where((s) => s.isActive).toList();
      case _FilterTab.selesai:
        return all.where((s) => s.isDone).toList();
    }
  }

  String _emptyMessage(bool hasAnySubmission) {
    if (!hasAnySubmission) {
      return 'Belum ada kontribusi nih. Yuk mulai angkut!';
    }
    switch (_selectedTab) {
      case _FilterTab.aktif:
        return 'Tidak ada distribusi yang sedang berjalan.';
      case _FilterTab.selesai:
        return 'Belum ada distribusi yang selesai.';
      case _FilterTab.semua:
        return 'Belum ada kontribusi nih. Yuk mulai angkut!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(riwayatProvider);

    return ColoredBox(
      color: AppColor.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
              child: Text(
                'Rekap Kontribusimu',
                style: AppTextStyle.subheading1Semibold.copyWith(
                  color: AppColor.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColor.brand,
                onRefresh: () => ref.read(riwayatProvider.notifier).refresh(),
                child: async.when(
                  loading: () => const _LoadingView(),
                  error: (err, _) => LayoutBuilder(
                    builder: (context, c) => SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: c.maxHeight),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColor.danger100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    err.toString(),
                                    textAlign: TextAlign.center,
                                    style: AppTextStyle.paragraph2Medium
                                        .copyWith(
                                          color: AppColor.danger,
                                        ),
                                  ),
                                  const Gap(12),
                                  TextButton(
                                    onPressed: () => ref
                                        .read(riwayatProvider.notifier)
                                        .refresh(),
                                    child: Text(
                                      'Coba lagi',
                                      style: AppTextStyle.paragraph2Semibold
                                          .copyWith(
                                            color: AppColor.brand,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  data: (data) {
                    final filtered = _filter(data.submissions);
                    final hasAny = data.submissions.isNotEmpty;

                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      children: [
                        // ── Aggregate Stats Header ──
                        _StatsHeader(stats: data.stats),
                        const Gap(16),

                        // ── Macro Insight Banner (PRD 8.7) ──
                        const _MacroRecapBanner(),
                        const Gap(24),

                        // ── Filter Tabs ──
                        Row(
                          children: [
                            Expanded(
                              child: _TabChip(
                                label: 'Semua',
                                selected: _selectedTab == _FilterTab.semua,
                                onTap: () => setState(
                                  () => _selectedTab = _FilterTab.semua,
                                ),
                              ),
                            ),
                            const Gap(8),
                            Expanded(
                              child: _TabChip(
                                label: 'Aktif',
                                selected: _selectedTab == _FilterTab.aktif,
                                onTap: () => setState(
                                  () => _selectedTab = _FilterTab.aktif,
                                ),
                              ),
                            ),
                            const Gap(8),
                            Expanded(
                              child: _TabChip(
                                label: 'Selesai',
                                selected: _selectedTab == _FilterTab.selesai,
                                onTap: () => setState(
                                  () => _selectedTab = _FilterTab.selesai,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Gap(16),

                        // ── Submission List / Empty State ──
                        if (filtered.isEmpty)
                          _EmptyState(
                            message: _emptyMessage(hasAny),
                            showCta: !hasAny,
                            onStartGrab: () {
                              ref.read(inputProvider.notifier).reset();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const InputScreen(),
                                ),
                              );
                            },
                          )
                        else
                          for (final item in filtered) ...[
                            _RecapItemCard(item: item),
                            const Gap(12),
                          ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroRecapBanner extends ConsumerWidget {
  const _MacroRecapBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final macroAsync = ref.watch(wawasanProvider);

    return InkWell(
      onTap: () => ref.read(mainTabProvider.notifier).state = 2,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColor.surfaceAlt),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColor.brand,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedLeaf02,
                  color: AppColor.textOnBrand,
                  size: 20,
                ),
              ),
            ),
            const Gap(12),
            Expanded(
              child: macroAsync.when(
                loading: () => Text(
                  'Sedang meracik dampakmu...',
                  style: AppTextStyle.paragraph2Regular.copyWith(
                    color: AppColor.textSecondary,
                  ),
                ),
                error: (err, _) => Text(
                  err is String ? err : kMacroFallback,
                  style: AppTextStyle.paragraph2Regular.copyWith(
                    color: AppColor.textSecondary,
                  ),
                ),
                data: (data) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wawasan Dampakmu',
                      style: AppTextStyle.paragraph2Semibold.copyWith(
                        color: AppColor.textPrimary,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      data.isEmpty
                          ? kMacroEmpty
                          : (data.insight ?? kMacroFallback),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.label1Regular.copyWith(
                        color: AppColor.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(8),
            const HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              color: AppColor.brand,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsHeader extends StatelessWidget {
  const _StatsHeader({required this.stats});
  final RecapStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.surfaceAlt),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatColumn(
              value: '${stats.totalKg.toStringAsFixed(1)} kg',
              label: 'Total Tersalurkan',
            ),
          ),
          Container(width: 1, height: 40, color: AppColor.surfaceAlt),
          Expanded(
            child: _StatColumn(
              value: '${stats.co2Saved.toStringAsFixed(1)} kg',
              label: 'CO₂ Dihemat (est.)',
            ),
          ),
          Container(width: 1, height: 40, color: AppColor.surfaceAlt),
          Expanded(
            child: _StatColumn(
              value: '${stats.totalUmkmHelped}',
              label: 'UMKM Terbantu',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: AppTextStyle.subheading1Semibold.copyWith(
            color: AppColor.brandDark,
          ),
        ),
        const Gap(4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyle.label1Regular.copyWith(
            color: AppColor.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColor.brand : AppColor.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColor.brand : AppColor.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyle.paragraph2Medium.copyWith(
            color: selected ? AppColor.textOnBrand : AppColor.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _RecapItemCard extends StatelessWidget {
  const _RecapItemCard({required this.item});
  final RecapSubmission item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => StatusScreen(submissionId: item.id),
        ),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColor.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.umkmNama,
                    style: AppTextStyle.paragraph1Semibold.copyWith(
                      color: AppColor.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: item.isDone ? AppColor.brandSoft : AppColor.surface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _statusLabels[item.status] ?? item.status,
                    style: AppTextStyle.label1Medium.copyWith(
                      color:
                          item.isDone ? AppColor.brandDark : AppColor.brand,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(6),
            Row(
              children: [
                Text(
                  '${item.beratKg} kg',
                  style: AppTextStyle.paragraph2Medium.copyWith(
                    color: AppColor.textPrimary,
                  ),
                ),
                const Gap(8),
                Text(
                  '· ${_formatDate(item.tanggal)}',
                  style: AppTextStyle.paragraph2Regular.copyWith(
                    color: AppColor.textSecondary,
                  ),
                ),
              ],
            ),
            const Gap(10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final t in item.tipeSampah)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.background200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      t,
                      style: AppTextStyle.label1Regular.copyWith(
                        color: AppColor.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.message,
    required this.showCta,
    required this.onStartGrab,
  });

  final String message;
  final bool showCta;
  final VoidCallback onStartGrab;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColor.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.cardBorder),
      ),
      child: Column(
        children: [
          const HugeIcon(
            icon: HugeIcons.strokeRoundedLeaf02,
            size: 40,
            color: AppColor.textDisabled,
          ),
          const Gap(12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyle.paragraph2Medium.copyWith(
              color: AppColor.textSecondary,
            ),
          ),
          if (showCta) ...[
            const Gap(20),
            CustomCtaButton(
              label: 'Mulai Angkut',
              onTap: onStartGrab,
            ),
          ],
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    Widget box(double h) => Container(
          height: h,
          decoration: BoxDecoration(
            color: AppColor.skeleton,
            borderRadius: BorderRadius.circular(16),
          ),
        );
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: [
        box(84),
        const Gap(24),
        box(44),
        const Gap(16),
        box(96),
        const Gap(12),
        box(96),
      ],
    );
  }
}

