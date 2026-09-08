import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_text_styles.dart';

/// Theme tối duy nhất của app, dựng từ bảng màu trích ở Figma.
class AppTheme {
  AppTheme._();

  static const _scheme = ColorScheme.dark(
    primary: AppColors.equals,
    onPrimary: AppColors.onEquals,
    secondary: AppColors.operator,
    onSecondary: AppColors.onOperator,
    error: AppColors.danger,
    onError: AppColors.onDanger,
    surface: AppColors.background,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.surfaceAlt,
    outline: AppColors.textSecondary,
  );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: _scheme,
        scaffoldBackgroundColor: AppColors.background,
        canvasColor: AppColors.background,
        splashColor: AppColors.accent.withValues(alpha: .12),
        highlightColor: AppColors.accent.withValues(alpha: .08),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ).apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
        appBarTheme: AppBarTheme(
          toolbarHeight: AppDimens.headerHeight,
          backgroundColor: AppColors.background.withValues(alpha: .8),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: AppTextStyles.title,
          iconTheme: const IconThemeData(color: AppColors.textSecondary),
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: AppDimens.navHeight,
          backgroundColor: AppColors.displayPanel,
          surfaceTintColor: Colors.transparent,
          indicatorColor: Colors.transparent,
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => AppTextStyles.caption.copyWith(
              color: states.contains(WidgetState.selected)
                  ? AppColors.accent
                  : AppColors.textSecondary,
            ),
          ),
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              size: 20,
              color: states.contains(WidgetState.selected)
                  ? AppColors.accent
                  : AppColors.textSecondary,
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusKey),
          ),
        ),
        dividerTheme: DividerThemeData(
          color: AppColors.textSecondary.withValues(alpha: .12),
          space: 1,
          thickness: 1,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusKey),
            borderSide: BorderSide.none,
          ),
          hintStyle: AppTextStyles.expression,
        ),
      );
}
