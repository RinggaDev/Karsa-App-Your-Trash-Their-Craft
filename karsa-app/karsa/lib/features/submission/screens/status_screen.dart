// lib/features/submission/screens/status_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:karsa/core/constants/app_colors.dart';
import 'package:karsa/core/constants/app_text_style.dart';
import 'package:karsa/core/providers/status_provider.dart';
import 'package:karsa/features/home/widgets/CTA_button.dart';
import 'package:karsa/features/summary/screens/summary_screen.dart';
import 'package:karsa/shared/widgets/main_shell.dart';

class StatusScreen extends ConsumerWidget {
  const StatusScreen({super.key, required this.submissionId});

  final String submissionId;

  static const _statusList = ['pending', 'confirmed', 'picked_up', 'done'];
  static const _statusLabels = {
    'pending': 'Pending',
    'confirmed': 'Dikonfirmasi',
    'picked_up': 'Dijemput',
    'done': 'Selesai',
  };
  static const _statusDesc = {
    'pending': 'Request kamu udah terkirim! Lagi nunggu konfirmasi.',
    'confirmed': 'UMKM udah konfirmasi dan lagi jadwalin pickup-nya.',
    'picked_up': 'Sampahmu udah dijemput! Sebentar lagi jadi karya keren.',
    'done': 'Selesai! Sampahmu udah ada di tangan yang tepat.',
  };
  static const _statusIcons = {
    'pending': HugeIcons.strokeRoundedTime02,
    'confirmed': HugeIcons.strokeRoundedCalendar03,
    'picked_up': HugeIcons.strokeRoundedDeliveryTruck01,
    'done': HugeIcons.strokeRoundedCheckmarkBadge01,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(submissionNotifierProvider(submissionId));

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
          onPressed: () {
            ref.read(mainTabProvider.notifier).state = 0;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainShell()),
              (_) => false,
            );
          },
        ),
        title: Text(
          'Status Distribusi',
          style: AppTextStyle.subheading1Semibold.copyWith(
            color: AppColor.textPrimary,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColor.brand,
        onRefresh: () async {
          debugPrint('🔄 RefreshIndicator triggered for $submissionId');
          await ref
              .read(submissionNotifierProvider(submissionId).notifier)
              .refresh(submissionId);
        },
        child: detailAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColor.brand),
          ),
          error: (err, _) => LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          err.toString(),
                          textAlign: TextAlign.center,
                          style: AppTextStyle.paragraph2Medium.copyWith(
                            color: AppColor.danger,
                          ),
                        ),
                        const Gap(12),
                        TextButton(
                          onPressed: () => ref
                              .read(
                                submissionNotifierProvider(
                                  submissionId,
                                ).notifier,
                              )
                              .refresh(submissionId),
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
                ),
              ),
            ),
          ),
          data: (sub) {
            final currentStatus = sub['status'] as String? ?? 'pending';
            debugPrint('🖼️ Rendering status screen with: $currentStatus');
            final currentIndex = _statusList.indexOf(currentStatus);
            final isDone = currentStatus == 'done';
            final umkm = sub['umkm'] as Map<String, dynamic>? ?? {};

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                // UMKM Info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColor.surfaceWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColor.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        umkm['nama'] as String? ?? 'UMKM Tujuan',
                        style: AppTextStyle.subheading2Semibold.copyWith(
                          color: AppColor.textPrimary,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        umkm['lokasi'] as String? ?? '',
                        style: AppTextStyle.paragraph2Regular.copyWith(
                          color: AppColor.textSecondary,
                        ),
                      ),
                      const Divider(color: AppColor.divider, height: 24),
                      Text(
                        '${(sub['tipe_sampah'] as List? ?? []).join(', ')} · ${sub['berat_kg']} kg',
                        style: AppTextStyle.paragraph2Medium.copyWith(
                          color: AppColor.brandDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Langkah Distribusi',
                      style: AppTextStyle.subheading2Semibold.copyWith(
                        color: AppColor.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDone ? AppColor.brandSoft : AppColor.surfaceAlt,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isDone
                            ? 'Selesai'
                            : 'Langkah ${currentIndex + 1} dari ${_statusList.length}',
                        style: AppTextStyle.label1Semibold.copyWith(
                          color: isDone ? AppColor.brandDark : AppColor.brand,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(16),
                // Timeline Container Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColor.surfaceWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColor.cardBorder),
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < _statusList.length; i++) ...[
                        Builder(
                          builder: (context) {
                            final isPassed = i < currentIndex;
                            final isCurrent = i == currentIndex;
                            final isPending = i > currentIndex;
                            final statusKey = _statusList[i];
                            final iconData = _statusIcons[statusKey]!;
                            final isLast = i == _statusList.length - 1;

                            return IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left indicator & connector line
                                  SizedBox(
                                    width: 38,
                                    child: Column(
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isPassed
                                                ? AppColor.brand
                                                : isCurrent
                                                    ? AppColor.brandSoft
                                                    : AppColor.background200,
                                            border: Border.all(
                                              color: isPassed || isCurrent
                                                  ? AppColor.brand
                                                  : AppColor.cardBorder,
                                              width: isCurrent ? 2 : 1.5,
                                            ),
                                          ),
                                          child: Center(
                                            child: HugeIcon(
                                              icon: isPassed
                                                  ? HugeIcons.strokeRoundedCheckmarkBadge01
                                                  : iconData,
                                              size: 18,
                                              color: isPassed
                                                  ? AppColor.textOnBrand
                                                  : isCurrent
                                                      ? AppColor.brand
                                                      : AppColor.textDisabled,
                                            ),
                                          ),
                                        ),
                                        if (!isLast)
                                          Expanded(
                                            child: Container(
                                              width: 2.5,
                                              margin: const EdgeInsets.symmetric(vertical: 4),
                                              decoration: BoxDecoration(
                                                color: isPassed
                                                    ? AppColor.brand
                                                    : AppColor.divider,
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const Gap(14),
                                  // Right content card / details
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        bottom: isLast ? 0 : 20,
                                        top: 2,
                                      ),
                                      child: Container(
                                        padding: isCurrent
                                            ? const EdgeInsets.all(12)
                                            : EdgeInsets.zero,
                                        decoration: isCurrent
                                            ? BoxDecoration(
                                                color: AppColor.surface50,
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: AppColor.primary200,
                                                ),
                                              )
                                            : null,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    _statusLabels[statusKey]!,
                                                    style: (isCurrent
                                                            ? AppTextStyle.paragraph1Bold
                                                            : AppTextStyle.paragraph1Semibold)
                                                        .copyWith(
                                                      color: isPending
                                                          ? AppColor.textDisabled
                                                          : isCurrent
                                                              ? AppColor.brandDark
                                                              : AppColor.textPrimary,
                                                    ),
                                                  ),
                                                ),
                                                if (isCurrent)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: AppColor.brand,
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Text(
                                                      'Sedang Berjalan',
                                                      style: AppTextStyle.label2Semibold.copyWith(
                                                        color: AppColor.textOnBrand,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const Gap(4),
                                            Text(
                                              _statusDesc[statusKey]!,
                                              style: AppTextStyle.paragraph2Regular.copyWith(
                                                color: isPending
                                                    ? AppColor.textDisabled
                                                    : AppColor.textSecondary,
                                                height: 1.35,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const Gap(32),

                // Tombol Lihat Dampakmu (hanya muncul saat status === 'done')
                if (isDone) ...[
                  CustomCtaButton(
                    label: 'Lihat Dampakmu',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            SummaryScreen(submissionId: submissionId),
                      ),
                    ),
                  ),
                  const Gap(16),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
