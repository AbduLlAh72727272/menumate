import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';

/// MenuMate Theme Configuration
/// Provides sophisticated theming with custom typography, elevations, and component styles
class MenuMateTheme {
  
  // Custom Typography Scale
  static const String fontFamily = 'SF Pro Display'; // Can be customized
  
  static TextTheme get _baseTextTheme => const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.1,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.25,
      height: 1.2,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.3,
    ),
    headlineLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.3,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      height: 1.4,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      height: 1.4,
    ),
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      height: 1.5,
    ),
    titleMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.5,
    ),
    titleSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.5,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.5,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.25,
      height: 1.4,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.25,
      height: 1.4,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.5,
      height: 1.4,
    ),
  );

  // Light Theme
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: MenuMateColorScheme.lightColorScheme,
    textTheme: _baseTextTheme.apply(
      bodyColor: MenuMateColors.charcoalBlack,
      displayColor: MenuMateColors.charcoalBlack,
      fontFamily: fontFamily,
    ),
    
    // App Bar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: MenuMateColors.deepLagoon,
      foregroundColor: MenuMateColors.pureWhite,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: _baseTextTheme.headlineMedium?.copyWith(
        color: MenuMateColors.pureWhite,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: MenuMateColors.citrusSpark,
        foregroundColor: MenuMateColors.charcoalBlack,
        elevation: 8,
        shadowColor: MenuMateColors.citrusSpark.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: _baseTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontFamily: fontFamily,
        ),
      ),
    ),
    
    // Card Theme
    cardTheme: const CardThemeData(
      color: MenuMateColors.pureWhite,
      elevation: 8,
      shadowColor: MenuMateColors.charcoalBlack,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      margin: EdgeInsets.all(8),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: MenuMateColors.pureWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: MenuMateColors.mediumGray.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: MenuMateColors.mediumGray.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: MenuMateColors.deepLagoon, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: MenuMateColors.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: MenuMateColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    
    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: MenuMateColors.pureWhite,
      selectedItemColor: MenuMateColors.deepLagoon,
      unselectedItemColor: MenuMateColors.mediumGray,
      type: BottomNavigationBarType.fixed,
      elevation: 16,
    ),
    
    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: MenuMateColors.mintFog.withOpacity(0.2),
      selectedColor: MenuMateColors.mintFog,
      disabledColor: MenuMateColors.lightGray.withOpacity(0.3),
      labelStyle: _baseTextTheme.bodyMedium?.copyWith(
        color: MenuMateColors.charcoalBlack,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    
    // FloatingActionButton Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: MenuMateColors.citrusSpark,
      foregroundColor: MenuMateColors.charcoalBlack,
      elevation: 12,
      shape: CircleBorder(),
    ),
    
    // Scaffold Background
    scaffoldBackgroundColor: MenuMateColors.cloudWhite,
  );

  // Dark Theme
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: MenuMateColorScheme.darkColorScheme,
    textTheme: _baseTextTheme.apply(
      bodyColor: MenuMateColors.cloudWhite,
      displayColor: MenuMateColors.cloudWhite,
      fontFamily: fontFamily,
    ),
    
    // App Bar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: MenuMateColors.charcoalBlack,
      foregroundColor: MenuMateColors.cloudWhite,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: _baseTextTheme.headlineMedium?.copyWith(
        color: MenuMateColors.cloudWhite,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: MenuMateColors.citrusSpark,
        foregroundColor: MenuMateColors.charcoalBlack,
        elevation: 8,
        shadowColor: MenuMateColors.citrusSpark.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: _baseTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontFamily: fontFamily,
        ),
      ),
    ),
    
    // Card Theme
    cardTheme: const CardThemeData(
      color: Color(0xFF2A2F2F),
      elevation: 8,
      shadowColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      margin: EdgeInsets.all(8),
    ),
    
    // Scaffold Background
    scaffoldBackgroundColor: MenuMateColors.charcoalBlack,
  );
}