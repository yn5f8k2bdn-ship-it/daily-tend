import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(brightness: Brightness.light);
  static ThemeData dark() => _build(brightness: Brightness.dark);

  static ThemeData _build({required Brightness brightness}) {
    final isLight = brightness == Brightness.light;

    final colorScheme = isLight
        ? const ColorScheme(
            brightness: Brightness.light,
            primary: AppColors.lightPrimary,
            onPrimary: AppColors.lightOnPrimary,
            primaryContainer: AppColors.lightPrimaryContainer,
            onPrimaryContainer: AppColors.lightOnPrimaryContainer,
            secondary: AppColors.lightSecondary,
            onSecondary: AppColors.lightOnSecondary,
            secondaryContainer: AppColors.lightSecondaryContainer,
            onSecondaryContainer: AppColors.lightOnSecondaryContainer,
            tertiary: AppColors.zoneSelf,
            onTertiary: Colors.white,
            error: AppColors.lightError,
            onError: Colors.white,
            surface: AppColors.lightSurface,
            onSurface: AppColors.lightOnSurface,
            surfaceContainerLowest: AppColors.lightSurfaceElevated,
            surfaceContainerLow: AppColors.lightSurface,
            surfaceContainer: AppColors.lightBg,
            surfaceContainerHigh: AppColors.lightBg,
            surfaceContainerHighest: AppColors.lightBg,
            outline: AppColors.lightOnSurfaceTertiary,
            outlineVariant: AppColors.lightDivider,
            shadow: Colors.black,
          )
        : const ColorScheme(
            brightness: Brightness.dark,
            primary: AppColors.darkPrimary,
            onPrimary: AppColors.darkOnPrimary,
            primaryContainer: AppColors.darkPrimaryContainer,
            onPrimaryContainer: AppColors.darkOnPrimaryContainer,
            secondary: AppColors.darkSecondary,
            onSecondary: AppColors.darkOnSecondary,
            secondaryContainer: AppColors.darkSecondaryContainer,
            onSecondaryContainer: AppColors.darkOnSecondaryContainer,
            tertiary: AppColors.zoneSelfDark,
            onTertiary: Colors.black,
            error: AppColors.darkError,
            onError: Colors.black,
            surface: AppColors.darkSurface,
            onSurface: AppColors.darkOnSurface,
            surfaceContainerLowest: AppColors.darkBg,
            surfaceContainerLow: AppColors.darkSurface,
            surfaceContainer: AppColors.darkSurfaceElevated,
            surfaceContainerHigh: AppColors.darkSurfaceElevated,
            surfaceContainerHighest: AppColors.darkSurfaceElevated,
            outline: AppColors.darkOnSurfaceTertiary,
            outlineVariant: AppColors.darkDivider,
            shadow: Colors.black,
          );

    final textTheme = _buildTextTheme(colorScheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // Transparent so the app-wide GradientBackground shows through every screen.
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: textTheme,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          side: BorderSide(color: colorScheme.outline),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
    );
  }

  /// Type scale per design system §3 — Inter, body sizes one step larger
  /// than Material default for one-handed reading.
  static TextTheme _buildTextTheme(ColorScheme cs) {
    final base = GoogleFonts.interTextTheme();
    final onSurface = cs.onSurface;

    return base.copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 40,
        height: 48 / 40,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.25,
        color: onSurface,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 32,
        height: 40 / 32,
        fontWeight: FontWeight.w500,
        color: onSurface,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 28,
        height: 36 / 28,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        height: 26 / 18,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: onSurface,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: onSurface,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 17,
        height: 26 / 17,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        color: onSurface,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 15,
        height: 22 / 15,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        color: onSurface,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: onSurface,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 15,
        height: 20 / 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: onSurface,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 13,
        height: 16 / 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: onSurface,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        height: 14 / 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: onSurface,
      ),
    );
  }
}
