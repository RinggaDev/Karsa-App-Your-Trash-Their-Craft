// lib/features/pengantaran/screens/pengantaran_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:karsa/core/constants/app_colors.dart';
import 'package:karsa/core/constants/app_text_style.dart';
import 'package:karsa/core/providers/home_provider.dart';
import 'package:karsa/core/providers/pengantaran_provider.dart';
import 'package:karsa/features/submission/screens/status_screen.dart';

const _statusLabels = {
  'pending': 'Menunggu',
  'confirmed': 'Dikonfirmasi',
  'picked_up': 'Dijemput',
  'done': 'Selesai',
};

class PengantaranScreen extends ConsumerWidget {
  const PengantaranScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(pengantaranProvider);

    return Scaffold(
      backgroundColor: AppColor.background,
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
          'Pengantaran',
          style: AppTextStyle.subheading1Semibold.copyWith(
            color: AppColor.textPrimary,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColor.brand,
        onRefresh: () async => ref.refresh(pengantaranProvider.future),
        child: async.when(
          loading: () => const _LoadingList(),
          error: (e, _) => _Scrollable(
            child: _ErrorBox(
              message: e is String
                  ? e
                  : 'Ada yang gak beres nih. Coba lagi dalam beberapa saat.',
              onRetry: () => ref.invalidate(pengantaranProvider),
            ),
          ),
          data: (list) {
            if (list.isEmpty) {
              return const _Scrollable(child: _EmptyBox());
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: list.length,
              separatorBuilder: (context, index) => const Gap(12),
              itemBuilder: (context, i) => _Item(item: list[i]),
            );
          },
        ),
      ),
    );
  }
}

/// Supaya pull-to-refresh tetap jalan di state kosong / error.
class _Scrollable extends StatelessWidget {
  const _Scrollable({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.item});
  final ActiveSubmission item;

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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.umkmNama,
                    style: AppTextStyle.paragraph1Semibold.copyWith(
                      color: AppColor.textPrimary,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    '${item.beratKg} kg',
                    style: AppTextStyle.paragraph2Regular.copyWith(
                      color: AppColor.textSecondary,
                    ),
                  ),
                  const Gap(8),
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
            const Gap(12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColor.surface,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _statusLabels[item.status] ?? item.status,
                style: AppTextStyle.label1Medium.copyWith(
                  color: AppColor.brand,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const HugeIcon(
            icon: HugeIcons.strokeRoundedLeaf02,
            size: 48,
            color: AppColor.textDisabled,
          ),
          const Gap(16),
          Text(
            'Tidak ada distribusi yang sedang berjalan. Santai dulu ya!',
            textAlign: TextAlign.center,
            style: AppTextStyle.paragraph2Medium.copyWith(
              color: AppColor.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              message,
              textAlign: TextAlign.center,
              style: AppTextStyle.paragraph2Medium.copyWith(
                color: AppColor.danger,
              ),
            ),
            const Gap(12),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Coba lagi',
                style: AppTextStyle.paragraph2Semibold.copyWith(
                  color: AppColor.brand,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: 4,
      separatorBuilder: (context, index) => const Gap(12),
      itemBuilder: (context, i) => Container(
        height: 88,
        decoration: BoxDecoration(
          color: AppColor.skeleton,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
