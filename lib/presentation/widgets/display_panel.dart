import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';

class DisplayPanel extends StatelessWidget {
  const DisplayPanel({
    super.key,
    required this.expression,
    required this.result,
    required this.memoryLabel,
    required this.hasMemory,
    required this.angleUnit,
    required this.onToggleAngle,
    this.note,
    this.isError = false,
  });

  final String expression;
  final String result;
  final String memoryLabel;
  final bool hasMemory;
  final String angleUnit;
  final VoidCallback onToggleAngle;
  final String? note;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusKey),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 25,
            offset: Offset(0, 20),
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusKey),
        child: Container(
          color: AppColors.displayPanel,
          constraints: const BoxConstraints(
            minHeight: AppDimens.panelMinHeight,
          ),
          child: Stack(
            children: [
              // Vòng sáng góc phải trên (Figma node 1:7)
              Positioned(
                right: -64,
                top: -64,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
                  child: Container(
                    width: 176,
                    height: 176,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.glow,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StatusRow(
                      memoryLabel: memoryLabel,
                      hasMemory: hasMemory,
                      angleUnit: angleUnit,
                      onToggleAngle: onToggleAngle,
                    ),
                    const SizedBox(height: 20),
                    // Biểu thức đang gõ
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        expression.isEmpty ? ' ' : expression,
                        style: AppTextStyles.expression,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _ResultRow(result: result, isError: isError),
                    const SizedBox(height: 6),
                    if (note != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.functions,
                            size: 12,
                            color: AppColors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            note!,
                            style: AppTextStyles.expression.copyWith(
                              fontSize: 12,
                              color: AppColors.amber,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.memoryLabel,
    required this.hasMemory,
    required this.angleUnit,
    required this.onToggleAngle,
  });

  final String memoryLabel;
  final bool hasMemory;
  final String angleUnit;
  final VoidCallback onToggleAngle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            // color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            // children: [
            //   Container(
            //     width: 6,
            //     height: 6,
            //     decoration: BoxDecoration(
            //       shape: BoxShape.circle,
            //       color: hasMemory
            //           ? AppColors.cyan
            //           : AppColors.textSecondary.withValues(alpha: .5),
            //       boxShadow: hasMemory
            //           ? const [BoxShadow(color: AppColors.cyan, blurRadius: 8)]
            //           : null,
            //     ),
            //   ),
            //   const SizedBox(width: 6),
            //   Text(
            //     memoryLabel,
            //     style: AppTextStyles.label.copyWith(color: AppColors.onCyan),
            //   ),
            // ],
          ),
        ),
        Row(
          children: [
            InkWell(
              onTap: onToggleAngle,
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text(
                  angleUnit,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textSecondary.withValues(alpha: .7),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.copy_rounded,
                size: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.result, required this.isError});

  final String result;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: FittedBox(
            alignment: Alignment.centerRight,
            fit: BoxFit.scaleDown,
            child: Text(
              result,
              maxLines: 1,
              style: AppTextStyles.result.copyWith(
                color: isError ? AppColors.onDanger : AppColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        // Container(
        //   width: 3,
        //   height: 28,
        //   decoration: BoxDecoration(
        //     color: AppColors.accent,
        //     borderRadius: BorderRadius.circular(2),
        //   ),
        // ),
      ],
    );
  }
}
