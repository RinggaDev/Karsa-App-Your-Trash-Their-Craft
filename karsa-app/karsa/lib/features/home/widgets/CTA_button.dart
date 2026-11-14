import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          // 1. Container defines the exact size FIRST
          child: Container(
            height: 60,
            width: double.infinity,
            // 2. Stack fills the container safely
            child: Stack(
              children: [
                // The SVG Background
                Positioned.fill(
                  child: SvgPicture.asset(
                    'assets/images/components/overlay_cta_button.svg',
                    // Try BoxFit.fill first. If it stretches weirdly, change to BoxFit.cover
                    fit: BoxFit.fill,
                  ),
                ),

                // The Content
                Padding(
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
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowRight02,
                          strokeWidth: 2,
                          color: AppColor.text100,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
