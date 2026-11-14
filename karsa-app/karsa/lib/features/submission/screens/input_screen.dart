// lib/features/submission/screens/input_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:karsa/core/constants/app_colors.dart';
import 'package:karsa/core/constants/app_text_style.dart';
import 'package:karsa/core/providers/input_provider.dart';
import 'package:karsa/features/home/widgets/CTA_button.dart';
import 'package:karsa/features/submission/screens/umkm_list_screen.dart';

const _bulan = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

String _formatTanggal(DateTime d) =>
    '${d.day} ${_bulan[d.month - 1]} ${d.year}';

class InputScreen extends ConsumerStatefulWidget {
  const InputScreen({super.key});

  @override
  ConsumerState<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends ConsumerState<InputScreen> {
  late final TextEditingController _beratController;
  late final TextEditingController _pickupController;
  late final TextEditingController _catatanController;

  @override
  void initState() {
    super.initState();
    // Isi dari state supaya data bertahan saat user kembali dari screen berikutnya
    final s = ref.read(inputProvider);
    _beratController = TextEditingController(
      text: s.beratKg == null ? '' : s.beratKg.toString(),
    );
    _pickupController = TextEditingController(text: s.pickupPoint);
    _catatanController = TextEditingController(text: s.catatan);
  }

  @override
  void dispose() {
    _beratController.dispose();
    _pickupController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String hint, {String? suffix}) => InputDecoration(
    hintText: hint,
    hintStyle: AppTextStyle.paragraph2Medium.copyWith(
      color: AppColor.textDisabled,
    ),
    suffixText: suffix,
    suffixStyle: AppTextStyle.paragraph2Medium.copyWith(
      color: AppColor.textSecondary,
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final current = ref.read(inputProvider).tanggalPickup;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 1, now.month, now.day),
      helpText: 'Pilih tanggal pickup',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );
    if (picked != null) ref.read(inputProvider.notifier).setTanggal(picked);
  }

  void _showPhotoSource() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColor.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ambil foto dari mana?',
                style: AppTextStyle.subheading1Semibold.copyWith(
                  color: AppColor.textPrimary,
                ),
              ),
              const Gap(12),
              _SourceTile(
                icon: HugeIcons.strokeRoundedCamera01,
                label: 'Kamera',
                onTap: () {
                  Navigator.of(ctx).pop();
                  ref
                      .read(inputProvider.notifier)
                      .pickAndUpload(
                        ImageSource.camera,
                      );
                },
              ),
              _SourceTile(
                icon: HugeIcons.strokeRoundedImage01,
                label: 'Galeri',
                onTap: () {
                  Navigator.of(ctx).pop();
                  ref
                      .read(inputProvider.notifier)
                      .pickAndUpload(
                        ImageSource.gallery,
                      );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _next() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const UmkmListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(inputProvider);
    final notifier = ref.read(inputProvider.notifier);

    // Toast saat upload foto bermasalah (foto_url tetap null, user boleh lanjut)
    ref.listen<String?>(inputProvider.select((v) => v.uploadError), (
      prev,
      next,
    ) {
      if (next != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next)));
      }
    });

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
          'Detail Sampahmu',
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Tipe sampah ──
                    const _Label('Tipe sampah'),
                    const Gap(8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final e in kTipeSampah.entries)
                          _ChoiceChip(
                            label: e.value,
                            selected: s.tipeSampah.contains(e.key),
                            onTap: () => notifier.toggleTipe(e.key),
                          ),
                      ],
                    ),
                    const Gap(24),

                    // ── Foto ──
                    const _Label('Foto sampah'),
                    const Gap(8),
                    _PhotoBox(
                      path: s.fotoPath,
                      isUploading: s.isUploading,
                      uploaded: s.fotoUrl != null,
                      onTap: s.isUploading ? null : _showPhotoSource,
                      onRemove: s.isUploading ? null : notifier.removeFoto,
                    ),
                    const Gap(24),

                    // ── Berat ──
                    const _Label('Berat estimasi'),
                    const Gap(8),
                    TextFormField(
                      controller: _beratController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      textInputAction: TextInputAction.next,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: notifier.setBerat,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Ini diisi dulu ya.';
                        }
                        final n = double.tryParse(
                          v.trim().replaceAll(',', '.'),
                        );
                        if (n == null || n <= 0) {
                          return 'Isi berat lebih dari 0 ya.';
                        }
                        return null;
                      },
                      decoration: _decoration(
                        'Estimasi aja, gak harus presisi',
                        suffix: 'kg',
                      ),
                    ),
                    const Gap(24),

                    // ── Kondisi ──
                    const _Label('Kondisi sampah'),
                    const Gap(8),
                    Row(
                      children: [
                        Expanded(
                          child: _ChoiceChip(
                            label: 'Sudah dibersihkan',
                            selected: s.kondisi == kKondisiBersih,
                            expand: true,
                            onTap: () => notifier.setKondisi(kKondisiBersih),
                          ),
                        ),
                        const Gap(8),
                        Expanded(
                          child: _ChoiceChip(
                            label: 'Belum dibersihkan',
                            selected: s.kondisi == kKondisiKotor,
                            expand: true,
                            onTap: () => notifier.setKondisi(kKondisiKotor),
                          ),
                        ),
                      ],
                    ),
                    const Gap(24),

                    // ── Pickup point ──
                    const _Label('Pickup point'),
                    const Gap(8),
                    TextFormField(
                      controller: _pickupController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.sentences,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: notifier.setPickupPoint,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Ini diisi dulu ya.'
                          : null,
                      decoration: _decoration('Alamat atau patokan lokasi'),
                    ),
                    const Gap(24),

                    // ── Tanggal ──
                    const _Label('Tanggal pickup'),
                    const Gap(8),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 56),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColor.background200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                s.tanggalPickup == null
                                    ? 'Pilih tanggal'
                                    : _formatTanggal(s.tanggalPickup!),
                                style: AppTextStyle.paragraph2Medium.copyWith(
                                  color: s.tanggalPickup == null
                                      ? AppColor.textDisabled
                                      : AppColor.textPrimary,
                                ),
                              ),
                            ),
                            const HugeIcon(
                              icon: HugeIcons.strokeRoundedCalendar01,
                              color: AppColor.textSecondary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(24),

                    // ── Catatan ──
                    const _Label('Catatan (opsional)'),
                    const Gap(8),
                    TextFormField(
                      controller: _catatanController,
                      minLines: 2,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: notifier.setCatatan,
                      decoration: _decoration(
                        'Misal: 2 botol besar dan beberapa kantong',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── CTA ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: CustomCtaButton(
                label: 'Cari UMKM yang Cocok',
                enabled: s.isValid,
                onTap: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyle.paragraph2Medium.copyWith(
        color: AppColor.textPrimary,
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.expand = false,
  });

  final String label;
  final bool selected;
  final bool expand;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        alignment: expand ? Alignment.center : null,
        decoration: BoxDecoration(
          color: selected ? AppColor.brand : AppColor.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColor.brand : AppColor.cardBorder,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyle.paragraph2Medium.copyWith(
            color: selected ? AppColor.textOnBrand : AppColor.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _PhotoBox extends StatelessWidget {
  const _PhotoBox({
    required this.path,
    required this.isUploading,
    required this.uploaded,
    required this.onTap,
    required this.onRemove,
  });

  final String? path;
  final bool isUploading;
  final bool uploaded;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 180,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColor.background300,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.cardBorder),
        ),
        child: path == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const HugeIcon(
                    icon: HugeIcons.strokeRoundedCamera01,
                    color: AppColor.textSecondary,
                    size: 32,
                  ),
                  const Gap(8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Foto sampahmu di sini — biar UMKM tau apa yang mereka dapet!',
                      textAlign: TextAlign.center,
                      style: AppTextStyle.paragraph2Regular.copyWith(
                        color: AppColor.textSecondary,
                      ),
                    ),
                  ),
                ],
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(path!), fit: BoxFit.cover),
                  if (isUploading)
                    Container(
                      color: AppColor.textPrimary.withValues(alpha: 0.4),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColor.textOnBrand,
                        ),
                      ),
                    ),
                  if (!isUploading)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: InkWell(
                        onTap: onRemove,
                        child: Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColor.textPrimary,
                              shape: BoxShape.circle,
                            ),
                            child: const HugeIcon(
                              icon: HugeIcons.strokeRoundedCancel01,
                              color: AppColor.textOnBrand,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (uploaded && !isUploading)
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.brandDark,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Foto terupload ✓',
                          style: AppTextStyle.label1Medium.copyWith(
                            color: AppColor.textOnBrand,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final List<List<dynamic>> icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: 12,
      leading: HugeIcon(icon: icon, color: AppColor.brand, size: 24),
      title: Text(
        label,
        style: AppTextStyle.paragraph1Medium.copyWith(
          color: AppColor.textPrimary,
        ),
      ),
      onTap: onTap,
    );
  }
}
