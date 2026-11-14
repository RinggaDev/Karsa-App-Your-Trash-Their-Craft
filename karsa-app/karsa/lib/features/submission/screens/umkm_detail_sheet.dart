// lib/features/submission/screens/umkm_detail_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:karsa/core/constants/app_colors.dart';
import 'package:karsa/core/constants/app_text_style.dart';
import 'package:karsa/core/providers/umkm_provider.dart';
import 'package:karsa/features/home/widgets/CTA_button.dart';

class UmkmDetailSheet extends ConsumerWidget {
  const UmkmDetailSheet({
    super.key,
    required this.umkmId,
    required this.onSelect,
  });

  final String umkmId;
  final void Function(Umkm umkm) onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(umkmDetailProvider(umkmId));

    return Container(
      decoration: const BoxDecoration(
        color: AppColor.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: SafeArea(
        top: false,
        child: detailAsync.when(
          loading: () => const SizedBox(
            height: 250,
            child: Center(
              child: CircularProgressIndicator(color: AppColor.brand),
            ),
          ),
          error: (err, _) => SizedBox(
            height: 200,
            child: Center(
              child: Text(
                err is String ? err : 'Gagal memuat detail UMKM.',
                style: AppTextStyle.paragraph2Medium.copyWith(
                  color: AppColor.danger,
                ),
              ),
            ),
          ),
          data: (umkm) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColor.textDisabled,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Gap(20),
                Text(
                  umkm.nama,
                  style: AppTextStyle.heading3Semibold.copyWith(
                    color: AppColor.textPrimary,
                  ),
                ),
                const Gap(6),
                Row(
                  children: [
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedLocation01,
                      size: 16,
                      color: AppColor.brand,
                    ),
                    const Gap(4),
                    Text(
                      umkm.lokasi,
                      style: AppTextStyle.paragraph2Regular.copyWith(
                        color: AppColor.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Gap(16),
                if (umkm.deskripsi != null && umkm.deskripsi!.isNotEmpty) ...[
                  Text(
                    'Tentang UMKM',
                    style: AppTextStyle.paragraph1Semibold.copyWith(
                      color: AppColor.textPrimary,
                    ),
                  ),
                  const Gap(6),
                  Text(
                    umkm.deskripsi!,
                    style: AppTextStyle.paragraph2Regular.copyWith(
                      color: AppColor.textSecondary,
                    ),
                  ),
                  const Gap(16),
                ],
                if (umkm.produkDibuat != null && umkm.produkDibuat!.isNotEmpty) ...[
                  Text(
                    'Karya yang Dibuat',
                    style: AppTextStyle.paragraph1Semibold.copyWith(
                      color: AppColor.textPrimary,
                    ),
                  ),
                  const Gap(6),
                  Text(
                    umkm.produkDibuat!,
                    style: AppTextStyle.paragraph2Regular.copyWith(
                      color: AppColor.textSecondary,
                    ),
                  ),
                  const Gap(16),
                ],
                Text(
                  'Bahan Baku Diterima',
                  style: AppTextStyle.paragraph1Semibold.copyWith(
                    color: AppColor.textPrimary,
                  ),
                ),
                const Gap(8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final b in umkm.bahanBaku)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColor.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          b,
                          style: AppTextStyle.label1Medium.copyWith(
                            color: AppColor.brandDark,
                          ),
                        ),
                      ),
                  ],
                ),
                if (umkm.kontak != null && umkm.kontak!.isNotEmpty) ...[
                  const Gap(16),
                  Text(
                    'Kontak',
                    style: AppTextStyle.paragraph1Semibold.copyWith(
                      color: AppColor.textPrimary,
                    ),
                  ),
                  const Gap(6),
                  Text(
                    umkm.kontak!,
                    style: AppTextStyle.paragraph2Regular.copyWith(
                      color: AppColor.textSecondary,
                    ),
                  ),
                ],
                const Gap(24),
                CustomCtaButton(
                  label: 'Distribusikan ke Sini',
                  onTap: () {
                    Navigator.of(context).pop();
                    onSelect(umkm);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

