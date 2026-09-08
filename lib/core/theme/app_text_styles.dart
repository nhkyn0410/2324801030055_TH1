import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get result => GoogleFonts.jetBrainsMono(
    fontSize: 40,
    fontWeight: FontWeight.w300,
    height: 48 / 40,
    letterSpacing: -2,
    color: AppColors.textPrimary,
  );

  static TextStyle get expression => GoogleFonts.jetBrainsMono(
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: -0.35,
    color: AppColors.textSecondary.withValues(alpha: .8),
  );

  static TextStyle get label => GoogleFonts.jetBrainsMono(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 1,
    color: AppColors.textSecondary,
  );

  static TextStyle get digit => GoogleFonts.inter(
    fontSize: 26,
    fontWeight: FontWeight.w500,
    height: 32 / 26,
    color: AppColors.textPrimary,
  );

  static TextStyle get symbol => GoogleFonts.jetBrainsMono(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 28 / 22,
  );

  static TextStyle get caption => GoogleFonts.jetBrainsMono(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 14 / 11,
    letterSpacing: .66,
    color: AppColors.textSecondary,
  );

  static TextStyle get title => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 24 / 18,
    letterSpacing: -.45,
    color: AppColors.textPrimary,
  );
}
