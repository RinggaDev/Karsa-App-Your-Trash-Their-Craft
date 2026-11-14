// lib/features/splash_onboarding/screens/onboarding_2.dart

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:karsa/core/constants/app_colors.dart';
import 'package:karsa/core/constants/app_text_style.dart';
import 'package:karsa/features/auth/screens/sign_in.dart';

class Onboarding2 extends StatelessWidget {
  const Onboarding2({super.key});

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
                'assets/images/components/o_b_2.png',
                width: 320,
              ),
              //
              const Spacer(),

              Text(
                'Pantau jejak kontribusimu secara nyata!',
                textAlign: TextAlign.center,
                style: AppTextStyle.heading3Semibold.copyWith(
                  color: AppColor.textPrimary,
                ),
              ),
              const Gap(12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Setiap kilogram yang kamu salurkan tercatat jelas bersama estimasi pengurangan CO₂ dan insight personal dari Karsa AI.',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.paragraph2Regular.copyWith(
                    color: AppColor.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
              const Gap(28),

              // Indicator dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColor.textDisabled,
                    radius: 3,
                  ),
                  const Gap(6),
                  Container(
                    width: 20,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColor.brand,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
              const Gap(28),

              // CTA Mulai Karsa!
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (_) => false,
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
                    'Mulai Karsa!',
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
