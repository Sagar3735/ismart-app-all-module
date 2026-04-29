import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Use constant strings for font families to keep styles const
  static const _plusJakarta = 'Plus Jakarta Sans';
  static const _dmSans = 'DM Sans';

  static const heading1 = TextStyle(
    fontFamily: _plusJakarta,
    fontSize: 22,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );
  
  static const heading2 = TextStyle(
    fontFamily: _plusJakarta,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );
  
  static const heading3 = TextStyle(
    fontFamily: _plusJakarta,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  
  static const subtitle = TextStyle(
    fontFamily: _dmSans,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  
  static const body = TextStyle(
    fontFamily: _dmSans,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );
  
  static const bodyMedium = TextStyle(
    fontFamily: _dmSans,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  
  static const caption = TextStyle(
    fontFamily: _dmSans,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  
  static const label = TextStyle(
    fontFamily: _plusJakarta,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );
  
  static const buttonText = TextStyle(
    fontFamily: _plusJakarta,
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  );
}
