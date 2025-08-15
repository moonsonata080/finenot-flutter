import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary);
  static const TextStyle heading2 = TextStyle(
    fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const TextStyle heading3 = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const TextStyle heading4 = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const TextStyle body = TextStyle(
    fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.textPrimary);
  static const TextStyle body1 = TextStyle(
    fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.textPrimary);
  static const TextStyle body2 = TextStyle(
    fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textPrimary);
  static const TextStyle caption = TextStyle(
    fontSize: 12, fontWeight: FontWeight.normal, color: AppColors.textSecondary);
}
