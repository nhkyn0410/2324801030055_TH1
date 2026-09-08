import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';

class MemoryBar extends StatelessWidget {
  const MemoryBar({
    super.key,
    required this.hasMemory,
    required this.onMc,
    required this.onMr,
    required this.onMPlus,
    required this.onMMinus,
    this.onScientific,
  });

  final bool hasMemory;
  final VoidCallback onMc, onMr, onMPlus, onMMinus;
  final VoidCallback? onScientific;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.memoryTray,
              borderRadius: BorderRadius.circular(AppDimens.radiusKey),
            ),
            child: Row(
              children: [
                _MemButton('MC', onMc),
                const SizedBox(width: 6),
                _MemButton('MR', onMr, highlight: hasMemory),
                const SizedBox(width: 6),
                _MemButton('M+', onMPlus),
                const SizedBox(width: 6),
                _MemButton('M−', onMMinus),
              ],
            ),
          ),
        ),
        if (onScientific != null) ...[
          const SizedBox(width: 8),
          InkWell(
            onTap: onScientific,
            borderRadius: BorderRadius.circular(AppDimens.radiusKey),
            child: Container(
              height: 31,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppDimens.radiusKey),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'FX Khoa học',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 10,
                    color: AppColors.accent,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _MemButton extends StatelessWidget {
  const _MemButton(this.label, this.onTap, {this.highlight = false});

  final String label;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMemoryKey),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.radiusMemoryKey),
          child: SizedBox(
            height: 30,
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: highlight ? AppColors.onCyan : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
