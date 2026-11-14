// lib/shared/widgets/karsa_bottom_nav.dart

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:karsa/core/constants/app_colors.dart';
import 'package:karsa/core/constants/app_text_style.dart';

class KarsaBottomNav extends StatelessWidget {
  const KarsaBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<_NavTabItem> _items = [
    _NavTabItem(
      label: 'Beranda',
      icon: HugeIcons.strokeRoundedHome01,
    ),
    _NavTabItem(
      label: 'Riwayat',
      icon: HugeIcons.strokeRoundedTransactionHistory,
    ),
    _NavTabItem(
      label: 'Wawasan',
      icon: HugeIcons.strokeRoundedPlant03,
    ),
    _NavTabItem(
      label: 'Profil',
      icon: HugeIcons.strokeRoundedUser,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.surfaceWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: const Border(
          top: BorderSide(color: AppColor.cardBorder, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isSelected = index == currentIndex;

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  borderRadius: BorderRadius.circular(14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColor.surface
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: HugeIcon(
                          icon: item.icon,
                          size: 22,
                          strokeWidth: isSelected ? 2.2 : 1.8,
                          color: isSelected
                              ? AppColor.brand
                              : AppColor.textDisabled,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        item.label,
                        style: (isSelected
                                ? AppTextStyle.label1Semibold
                                : AppTextStyle.label1Regular)
                            .copyWith(
                          color: isSelected
                              ? AppColor.brand
                              : AppColor.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavTabItem {
  final String label;
  final List<List<dynamic>> icon;

  const _NavTabItem({
    required this.label,
    required this.icon,
  });
}

