import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';

enum KeyStyle { digit, function, science, operator, equals, danger }

class CalcKey {
  const CalcKey(
    this.label, {
    this.style = KeyStyle.digit,
    this.subLabel,
    this.token,
    this.fontSize,
  });

  final String label;
  final String? subLabel;
  final KeyStyle style;
  final String? token;
  final double? fontSize;

  String get value => token ?? label;
}

class CalcKeyButton extends StatelessWidget {
  const CalcKeyButton({
    super.key,
    required this.data,
    required this.onTap,
    this.height = AppDimens.keyHeight,
  });

  final CalcKey data;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, shadow) = _palette(data.style);
    final style = _textStyle(data.style, fg).copyWith(fontSize: data.fontSize);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppDimens.radiusKey),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusKey),
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusKey),
            boxShadow: shadow == null
                ? null
                : [
                    BoxShadow(
                      color: shadow,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(data.label, style: style, textAlign: TextAlign.center),
                if (data.subLabel != null)
                  Text(
                    data.subLabel!,
                    style: AppTextStyles.caption.copyWith(
                      color: fg.withValues(alpha: .7),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  (Color, Color, Color?) _palette(KeyStyle s) => switch (s) {
    KeyStyle.digit => (AppColors.surface, AppColors.textPrimary, null),
    KeyStyle.function => (AppColors.surfaceAlt, AppColors.textPrimary, null),
    KeyStyle.science => (AppColors.surfaceAlt, AppColors.accent, null),
    KeyStyle.operator => (
      AppColors.operator,
      AppColors.onOperator,
      AppColors.operator.withValues(alpha: .3),
    ),
    KeyStyle.equals => (
      AppColors.equals,
      AppColors.onEquals,
      AppColors.equals.withValues(alpha: .45),
    ),
    KeyStyle.danger => (
      AppColors.danger,
      AppColors.onDanger,
      AppColors.danger.withValues(alpha: .3),
    ),
  };

  TextStyle _textStyle(KeyStyle s, Color fg) => switch (s) {
    KeyStyle.digit => AppTextStyles.digit.copyWith(color: fg),
    KeyStyle.science => AppTextStyles.caption.copyWith(fontSize: 13, color: fg),
    _ => AppTextStyles.symbol.copyWith(color: fg),
  };
}
