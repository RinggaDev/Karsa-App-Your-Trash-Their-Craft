// lib/features/splash_onboarding/screens/onboarding_1.dart

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:karsa/core/constants/app_colors.dart';
import 'package:karsa/core/constants/app_text_style.dart';
import 'package:karsa/features/splash_onboarding/screens/onboarding_2.dart';

class Onboarding1 extends StatelessWidget {
  const Onboarding1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Gap(24),

              // Logo Pill
              const Spacer(),

              // Illustration Container
              Image.asset(
                'assets/images/components/o_b_1.png',
                width: 300,
              ),

              const Spacer(),

              Text(
                'Ubah sampah terpilah jadi karya bernilai!',
                textAlign: TextAlign.center,
                style: AppTextStyle.heading3Semibold.copyWith(
                  color: AppColor.text700,
                ),
              ),
              const Gap(12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Punya plastik, kardus, atau kain nganggur? Yuk salurkan langsung ke UMKM kerajinan lokal yang butuh bahan baku.',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.paragraph2Medium.copyWith(
                    color: AppColor.text300,
                    height: 1.5,
                  ),
                ),
              ),
              const Gap(28),

              // Indicator dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 20,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColor.brand,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const Gap(6),
                  const CircleAvatar(
                    backgroundColor: AppColor.textDisabled,
                    radius: 3,
                  ),
                ],
              ),
              const Gap(28),

              // CTA Lanjut
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const Onboarding2()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.brand,
                    foregroundColor: AppColor.textOnBrand,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Lanjut',
                    style: AppTextStyle.subheading2Semibold.copyWith(
                      color: AppColor.textOnBrand,
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
