import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:karsa/core/constants/app_colors.dart';
import 'package:karsa/core/constants/app_text_style.dart';
import 'package:karsa/core/providers/auth_provider.dart';
import 'package:karsa/core/providers/home_provider.dart';
import 'package:karsa/core/providers/input_provider.dart';
import 'package:karsa/features/home/widgets/CTA_button.dart';
import 'package:karsa/features/pengantaran/screens/pengantaran_screen.dart';
import 'package:karsa/features/submission/screens/input_screen.dart';
import 'package:karsa/features/submission/screens/status_screen.dart';
import 'package:karsa/shared/widgets/main_shell.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Tampilkan snackbar welcome/login/register sesaat setelah HomeScreen ter-render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final msg = ref.read(authProvider).welcomeMessage;
      if (msg != null && msg.isNotEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                msg,
                style: AppTextStyle.paragraph2Medium.copyWith(
                  color: AppColor.textOnBrand,
                ),
              ),
              backgroundColor: AppColor.brandDark,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        ref.read(authProvider.notifier).clearWelcomeMessage();
      }
    });
  }

  void _startGrab(BuildContext context, WidgetRef ref) {
    // Form baru tiap mulai angkut
    ref.read(inputProvider.notifier).reset();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const InputScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final home = ref.watch(homeProvider);

    return ColoredBox(
      color: AppColor.background,
      child: SafeArea(
        child: RefreshIndicator(
          color: AppColor.brand,
          onRefresh: () async => ref.refresh(homeProvider.future),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
            children: [
              // ── Greeting & Profile Icon ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hai, ${user?.nama ?? ''}!',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.heading4Semibold.copyWith(
                            color: AppColor.brand,
                          ),
                        ),
                        Text(
                          'Siap angkut hari ini?',
                          style: AppTextStyle.paragraph2Regular.copyWith(
                            color: AppColor.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => ref.read(mainTabProvider.notifier).state = 3,
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedUser,
                        strokeWidth: 2,
                        size: 24,
                        color: AppColor.brand,
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(29),

              // ── Stats + Active ──
              home.when(
                loading: () => const _HomeLoading(),
                error: (e, _) => _HomeError(
                  message: e is String
                      ? e
                      : 'Ada yang gak beres nih. Coba lagi dalam beberapa saat.',
                  onRetry: () => ref.invalidate(homeProvider),
                ),
                data: (data) => _HomeContent(
                  data: data,
                  onStartGrab: () => _startGrab(context, ref),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({
    required this.data,
    required this.onStartGrab,
  });
  final HomeData data;
  final VoidCallback onStartGrab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = data.stats;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Tersalurkan',
          style: AppTextStyle.paragraph2Regular.copyWith(
            color: AppColor.textSecondary,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              s.totalKg.toStringAsFixed(1),
              style: AppTextStyle.display2Semibold.copyWith(
                color: AppColor.text700,
              ),
            ),
            const Gap(6),
            Text(
              'kg',
              style: AppTextStyle.paragraph2Regular.copyWith(
                color: AppColor.textSecondary,
              ),
            ),
          ],
        ),
        const Gap(2),
        Row(
          children: [
            const HugeIcon(
              icon: HugeIcons.strokeRoundedLeaf02,
              size: 20,
              color: AppColor.brand,
              strokeWidth: 2,
            ),
            const Gap(4),
            Text(
              s.co2Saved.toStringAsFixed(0),
              style: AppTextStyle.paragraph1Semibold.copyWith(
                color: AppColor.text700,
              ),
            ),
            const Gap(2),
            Text(
              'kg CO₂ berkurang di bumi',
              style: AppTextStyle.paragraph1Medium.copyWith(
                color: AppColor.textSecondary,
              ),
            ),
          ],
        ),
        const Gap(20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColor.brand,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const HugeIcon(
                    icon: HugeIcons.strokeRoundedDeliveryTruck01,
                    color: AppColor.textOnBrand,
                    size: 20,
                  ),
                  const Gap(8),
                  Text(
                    '${s.totalSubmissions} kali setor sampah',
                    style: AppTextStyle.paragraph2Medium.copyWith(
                      color: AppColor.textOnBrand,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => ref.read(mainTabProvider.notifier).state = 1,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.brandSoft,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedTransactionHistory,
                        color: AppColor.brand,
                        size: 16,
                      ),
                      const Gap(4),
                      Text(
                        'Riwayat',
                        style: AppTextStyle.label1Semibold.copyWith(
                          color: AppColor.brand,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fitur',
              style: AppTextStyle.subheading2Medium.copyWith(
                color: AppColor.text700,
              ),
            ),
          ],
        ),
        const Gap(12),
        Container(
          decoration: BoxDecoration(
            color: AppColor.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 42),
          height: 130,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _QuickNavCard(
                  icon: HugeIcons.strokeRoundedDeliveryTruck01,
                  label: 'Pengantaran',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PengantaranScreen(),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: _QuickNavCard(
                  icon: HugeIcons.strokeRoundedPlant03,
                  label: 'Wawasan',
                  onTap: () => ref.read(mainTabProvider.notifier).state = 2,
                ),
              ),

              Expanded(
                child: _QuickNavCard(
                  icon: HugeIcons.strokeRoundedTransactionHistory,
                  label: 'Riwayat',
                  onTap: () => ref.read(mainTabProvider.notifier).state = 1,
                ),
              ),
            ],
          ),
        ),
        const Gap(24),
        CustomCtaButton(onTap: onStartGrab),
        const Gap(28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Distribusi Aktif',
              style: AppTextStyle.subheading2Medium.copyWith(
                color: AppColor.text700,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PengantaranScreen()),
              ),
              child: Text(
                'Lihat semua',
                style: AppTextStyle.paragraph2Semibold.copyWith(
                  color: AppColor.brand,
                ),
              ),
            ),
          ],
        ),
        const Gap(12),
        if (data.active.isEmpty)
          const _EmptyActive()
        else
          ...data.active.map((a) => _ActiveCard(item: a)),
      ],
    );
  }
}

class _QuickNavCard extends StatelessWidget {
  const _QuickNavCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final List<List<dynamic>> icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior
          .opaque, // Memastikan seluruh area (termasuk gap) bisa di-tap
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Bagian Kotak Tombol (Overlay + Ikon)
          ClipRRect(
            borderRadius: BorderRadius.circular(
              16,
            ), // Sesuaikan radius dengan di Figma
            child: SizedBox(
              width:
                  65, // Sesuaikan ukuran lebar kotak (di gambar terlihat kotak)
              height: 65, // Sesuaikan ukuran tinggi kotak
              child: Stack(
                children: [
                  // SVG Overlay Background
                  Positioned.fill(
                    child: SvgPicture.asset(
                      // GANTI PATH INI DENGAN PATH SVG OVERLAY KAMU
                      'assets/images/components/feature_button.svg',
                      fit: BoxFit.fill, // Atau BoxFit.cover
                    ),
                  ),

                  // Ikon di atas overlay
                  Center(
                    child: HugeIcon(
                      icon: icon,
                      color: Colors
                          .white, // Ubah warna ikon jadi putih sesuai desain
                      size: 40, // Sesuaikan ukuran ikon
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 6), // Jarak antara tombol dan teks
          // 2. Bagian Teks Label
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyle.label1Medium.copyWith(
              color:
                  AppColor.text700, // Pastikan warnanya gelap (hitam/abu tua)
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveCard extends StatelessWidget {
  const _ActiveCard({required this.item});
  final ActiveSubmission item;

  static const _labels = {
    'pending': 'Menunggu',
    'confirmed': 'Dikonfirmasi',
    'picked_up': 'Dijemput',
    'done': 'Selesai',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => StatusScreen(submissionId: item.id),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColor.surfaceWhite,
            borderRadius: BorderRadius.circular(12),
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
                      '${item.tipeSampah.join(', ')} · ${item.beratKg} kg',
                      style: AppTextStyle.paragraph2Regular.copyWith(
                        color: AppColor.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColor.surface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _labels[item.status] ?? item.status,
                  style: AppTextStyle.label1Medium.copyWith(
                    color: AppColor.brand,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyActive extends StatelessWidget {
  const _EmptyActive();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColor.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.surface),
      ),
      child: Column(
        children: [
          const HugeIcon(
            icon: HugeIcons.strokeRoundedLeaf02,
            size: 32,
            color: AppColor.textDisabled,
          ),
          const Gap(12),
          Text(
            'Belum ada distribusi aktif. Yuk mulai!',
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

class _HomeLoading extends ConsumerWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget bar(double h, double w) => Container(
      height: h,
      width: w,
      decoration: BoxDecoration(
        color: AppColor.skeleton,
        borderRadius: BorderRadius.circular(12),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        bar(14, 120),
        const Gap(12),
        bar(56, 180),
        const Gap(16),
        bar(44, double.infinity),
        const Gap(20),
        Row(
          children: [
            Expanded(
              child: _QuickNavCard(
                icon: HugeIcons.strokeRoundedDeliveryTruck01,
                label: 'Pengantaran',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PengantaranScreen()),
                ),
              ),
            ),
            const Gap(10),
            Expanded(
              child: _QuickNavCard(
                icon: HugeIcons.strokeRoundedPlant03,
                label: 'Wawasan',
                onTap: () => ref.read(mainTabProvider.notifier).state = 2,
              ),
            ),
            const Gap(10),
            Expanded(
              child: _QuickNavCard(
                icon: HugeIcons.strokeRoundedTransactionHistory,
                label: 'Riwayat',
                onTap: () => ref.read(mainTabProvider.notifier).state = 1,
              ),
            ),
          ],
        ),
        const Gap(28),
        bar(72, double.infinity),
      ],
    );
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.danger100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
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
    );
  }
}
