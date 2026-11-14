// lib/features/submission/screens/umkm_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:karsa/core/constants/app_colors.dart';
import 'package:karsa/core/constants/app_text_style.dart';
import 'package:karsa/core/providers/input_provider.dart';
import 'package:karsa/core/providers/umkm_provider.dart';
import 'package:karsa/features/submission/screens/status_screen.dart';
import 'package:karsa/features/submission/screens/umkm_detail_sheet.dart';

class UmkmListScreen extends ConsumerWidget {
  const UmkmListScreen({super.key});

  void _openDetail(BuildContext context, WidgetRef ref, String umkmId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => UmkmDetailSheet(
        umkmId: umkmId,
        onSelect: (umkm) => _showConfirmDialog(context, ref, umkm),
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, WidgetRef ref, Umkm umkm) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => Consumer(
        builder: (context, ref, _) {
          final submitState = ref.watch(submitProvider);

          return AlertDialog(
            backgroundColor: AppColor.surfaceWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Yakin mau kirim ke ${umkm.nama}?',
              style: AppTextStyle.subheading1Semibold.copyWith(
                color: AppColor.textPrimary,
              ),
            ),
            content: Text(
              'Nanti mereka akan dijadwalkan untuk pickup sesuai tanggal yang kamu pilih.',
              style: AppTextStyle.paragraph2Regular.copyWith(
                color: AppColor.textSecondary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: submitState.isLoading
                    ? null
                    : () => Navigator.of(dialogCtx).pop(),
                child: Text(
                  'Batal',
                  style: AppTextStyle.paragraph2Medium.copyWith(
                    color: AppColor.textSecondary,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: submitState.isLoading
                    ? null
                    : () async {
                        final subId = await ref
                            .read(submitProvider.notifier)
                            .submit(umkm.id);
                        if (subId != null && dialogCtx.mounted) {
                          Navigator.of(dialogCtx).pop();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => StatusScreen(submissionId: subId),
                            ),
                            (route) => route.isFirst,
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.brand,
                  foregroundColor: AppColor.textOnBrand,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: submitState.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColor.textOnBrand,
                        ),
                      )
                    : Text(
                        'Ya, Distribusikan!',
                        style: AppTextStyle.paragraph2Semibold.copyWith(
                          color: AppColor.textOnBrand,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipeQuery = ref.watch(inputProvider.select((s) => s.tipeSampahQuery));
    final umkmListAsync = ref.watch(umkmListProvider(tipeQuery));

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.background,
        elevation: 0,
        leading: IconButton(
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft02,
            color: AppColor.textPrimary,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Pilih UMKM Tujuan',
          style: AppTextStyle.subheading1Semibold.copyWith(
            color: AppColor.textPrimary,
          ),
        ),
      ),
      body: umkmListAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColor.brand),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                err.toString(),
                style: AppTextStyle.paragraph2Medium.copyWith(
                  color: AppColor.danger,
                ),
              ),
              const Gap(12),
              TextButton(
                onPressed: () => ref.refresh(umkmListProvider(tipeQuery)),
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
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedPackage,
                      size: 48,
                      color: AppColor.textDisabled,
                    ),
                    const Gap(16),
                    Text(
                      'Belum ada UMKM yang terima jenis sampah ini. Coba tipe lain?',
                      textAlign: TextAlign.center,
                      style: AppTextStyle.paragraph2Medium.copyWith(
                        color: AppColor.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            itemCount: list.length,
            separatorBuilder: (context, index) => const Gap(12),
            itemBuilder: (context, index) {
              final umkm = list[index];
              return InkWell(
                onTap: () => _openDetail(context, ref, umkm.id),
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
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColor.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedStore01,
                            color: AppColor.brand,
                            size: 24,
                          ),
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              umkm.nama,
                              style: AppTextStyle.paragraph1Semibold.copyWith(
                                color: AppColor.textPrimary,
                              ),
                            ),
                            const Gap(4),
                            Text(
                              umkm.lokasi,
                              style: AppTextStyle.paragraph2Regular.copyWith(
                                color: AppColor.textSecondary,
                              ),
                            ),
                            const Gap(8),
                            Wrap(
                              spacing: 6,
                              children: [
                                for (final tag in umkm.bahanBaku)
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
                                      tag,
                                      style: AppTextStyle.label2Regular.copyWith(
                                        color: AppColor.textSecondary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowRight01,
                        color: AppColor.textDisabled,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
