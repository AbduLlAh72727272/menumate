import 'package:flutter/material.dart';

/// MenuMate Color Scheme: "Deep Lagoon & Citrus Spark"
/// A sophisticated and modern palette that suggests quality and trust
/// while maintaining appetite appeal through strategic use of green/orange tones.
class MenuMateColors {
  // Primary - Trust & Depth
  static const Color deepLagoon = Color(0xFF006D77);
  static const Color deepLagoonLight = Color(0xFF4C9CA5);
  static const Color deepLagoonDark = Color(0xFF004349);
  
  // Accent - Energy & Action
  static const Color citrusSpark = Color(0xFFFF9F1C);
  static const Color citrusSparkLight = Color(0xFFFFB84D);
  static const Color citrusSparkDark = Color(0xFFE6800A);
  
  // Secondary - Freshness & Health
  static const Color mintFog = Color(0xFF83C5BE);
  static const Color mintFogLight = Color(0xFFA8D5D0);
  static const Color mintFogDark = Color(0xFF5EA69E);
  
  // Background & Surface
  static const Color cloudWhite = Color(0xFFF4F4F9);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color softGray = Color(0xFFE8E8ED);
  
  // Text & Icons
  static const Color charcoalBlack = Color(0xFF1C2525);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color lightGray = Color(0xFF9CA3AF);
  
  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Gradient Colors for advanced UI
  static const List<Color> lagoonGradient = [
    deepLagoon,
    deepLagoonLight,
  ];
  
  static const List<Color> citrusGradient = [
    citrusSpark,
    citrusSparkLight,
  ];
  
  static const List<Color> mintGradient = [
    mintFog,
    mintFogLight,
  ];
}

/// Custom ColorScheme for MenuMate
class MenuMateColorScheme {
  static ColorScheme get lightColorScheme => ColorScheme.light(
    primary: MenuMateColors.deepLagoon,
    primaryContainer: MenuMateColors.deepLagoonLight,
    secondary: MenuMateColors.citrusSpark,
    secondaryContainer: MenuMateColors.citrusSparkLight,
    tertiary: MenuMateColors.mintFog,
    tertiaryContainer: MenuMateColors.mintFogLight,
    surface: MenuMateColors.cloudWhite,
    surfaceContainerHighest: MenuMateColors.pureWhite,
    onPrimary: MenuMateColors.pureWhite,
    onSecondary: MenuMateColors.charcoalBlack,
    onTertiary: MenuMateColors.charcoalBlack,
    onSurface: MenuMateColors.charcoalBlack,
    error: MenuMateColors.error,
    onError: MenuMateColors.pureWhite,
    outline: MenuMateColors.mediumGray,
    outlineVariant: MenuMateColors.lightGray,
  );

  static ColorScheme get darkColorScheme => ColorScheme.dark(
    primary: MenuMateColors.deepLagoonLight,
    primaryContainer: MenuMateColors.deepLagoon,
    secondary: MenuMateColors.citrusSpark,
    secondaryContainer: MenuMateColors.citrusSparkDark,
    tertiary: MenuMateColors.mintFog,
    tertiaryContainer: MenuMateColors.mintFogDark,
    surface: MenuMateColors.charcoalBlack,
    surfaceContainerHighest: Color(0xFF2A2F2F),
    onPrimary: MenuMateColors.charcoalBlack,
    onSecondary: MenuMateColors.charcoalBlack,
    onTertiary: MenuMateColors.charcoalBlack,
    onSurface: MenuMateColors.cloudWhite,
    error: MenuMateColors.error,
    onError: MenuMateColors.charcoalBlack,
    outline: MenuMateColors.mediumGray,
    outlineVariant: MenuMateColors.lightGray,
  );
}