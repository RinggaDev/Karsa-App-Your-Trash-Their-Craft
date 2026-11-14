import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:karsa/core/constants/app_colors.dart';
import 'package:karsa/core/constants/app_text_style.dart';

class CustomCtaButton extends StatelessWidget {
  const CustomCtaButton({
    super.key,
    this.onTap,
    this.label = 'Mulai Berkontribusi',
    this.enabled = true,
  });

  final VoidCallback? onTap;
  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: GestureDetector(
          onTap: enabled ? onTap : null,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            // 1. Container defines the exact size FIRST
            child: Container(
              height: 60,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF86C576),
                    Color(0xFF63A156),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: AppTextStyle.subheading1Medium.copyWith(
                          color: AppColor.textOnBrand,
                        ),
                      ),
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowRight02,
                        strokeWidth: 2,
                        color: AppColor.text100,
                        size: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
