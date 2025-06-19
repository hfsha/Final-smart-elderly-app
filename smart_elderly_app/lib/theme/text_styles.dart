import 'package:flutter/material.dart';
import 'app_colors.dart';

class TextStyles {
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyText1 = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyText2 = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  // Dark Theme Variants
  static const TextStyle headline1Dark = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textLight,
  );

  static const TextStyle headline2Dark = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textLight,
  );
}
