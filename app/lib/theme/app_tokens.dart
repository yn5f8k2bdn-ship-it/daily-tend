import 'package:flutter/material.dart';

/// Design tokens — Dart mirror of `docs/design/tokens.json`.
///
/// Source of truth is the JSON file; this file translates it for Flutter.
/// If you change a value here, change it in tokens.json too (and vice versa).
class AppColors {
  AppColors._();

  // --- Light palette ---
  static const Color lightBg = Color(0xFFF7F2EC);
  static const Color lightSurface = Color(0xFFFFFBF5);
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF1F1B16);
  static const Color lightOnSurfaceSecondary = Color(0xFF5A534B);
  static const Color lightOnSurfaceTertiary = Color(0xFF8A8079);
  static const Color lightDivider = Color(0xFFE6DED3);
  static const Color lightOverlay = Color(0x661F1B16);

  // Primary = warm honey (founder decision 2026-04-29, replacing clay
  // after the teal-gradient experiment landed). Mid-century pair with the
  // teal gradient bg. Note: dark-brown text on honey, not white — white
  // on #D9A04C only hits 2.3:1 (fails AA Large), brown is 6.95:1 (AAA).
  static const Color lightPrimary = Color(0xFFD9A04C);
  static const Color lightOnPrimary = Color(0xFF2E1F0E);
  static const Color lightPrimaryContainer = Color(0xFFFBE5C7);
  static const Color lightOnPrimaryContainer = Color(0xFF4A2F0E);

  // Secondary = deep teal (sibling to the gradient teal #54A4AE).
  // Replaces sage 2026-04-29 — sage and gradient teal sat too close.
  static const Color lightSecondary = Color(0xFF2E6B73);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFC2DBDD);
  static const Color lightOnSecondaryContainer = Color(0xFF0E2F33);

  static const Color lightSuccess = Color(0xFF5C8A5E);
  static const Color lightWarning = Color(0xFFC99A3D);
  static const Color lightError = Color(0xFFB4544A);
  static const Color lightInfo = Color(0xFF5E7E99);

  // Three-Zone accents (frozen against Material You).
  static const Color zoneSelf = Color(0xFF6B8FA8);
  static const Color zoneSelfContainer = Color(0xFFD8E4EE);
  static const Color zonePurpose = Color(0xFFB8864A);
  static const Color zonePurposeContainer = Color(0xFFEEDFC7);
  static const Color zoneLovedOnes = Color(0xFFA8678A);
  static const Color zoneLovedOnesContainer = Color(0xFFEAD4DF);

  // --- Dark palette (warm dark, not OLED-void) ---
  static const Color darkBg = Color(0xFF1A1714);
  static const Color darkSurface = Color(0xFF221E1A);
  static const Color darkSurfaceElevated = Color(0xFF2C2722);
  static const Color darkOnSurface = Color(0xFFF1EAE0);
  static const Color darkOnSurfaceSecondary = Color(0xFFBDB3A6);
  static const Color darkOnSurfaceTertiary = Color(0xFF877E72);
  static const Color darkDivider = Color(0xFF38322C);

  static const Color darkPrimary = Color(0xFFE8B86E);
  static const Color darkOnPrimary = Color(0xFF2E1F0E);
  static const Color darkPrimaryContainer = Color(0xFF5C4220);
  static const Color darkOnPrimaryContainer = Color(0xFFFBE5C7);

  static const Color darkSecondary = Color(0xFF7FB5BC);
  static const Color darkOnSecondary = Color(0xFF0E2F33);
  static const Color darkSecondaryContainer = Color(0xFF1A4F58);
  static const Color darkOnSecondaryContainer = Color(0xFFC2DBDD);

  static const Color darkSuccess = Color(0xFF9AC49B);
  static const Color darkWarning = Color(0xFFE6BE7A);
  static const Color darkError = Color(0xFFE09189);
  static const Color darkInfo = Color(0xFF9BB4C9);

  static const Color zoneSelfDark = Color(0xFFA8C2D6);
  static const Color zoneSelfContainerDark = Color(0xFF2E404E);
  static const Color zonePurposeDark = Color(0xFFE2BA82);
  static const Color zonePurposeContainerDark = Color(0xFF4E3B22);
  static const Color zoneLovedOnesDark = Color(0xFFD9A7BC);
  static const Color zoneLovedOnesContainerDark = Color(0xFF4A2E3C);
}

class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
  static const double huge = 64;
}

class AppRadius {
  AppRadius._();
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double full = 9999;
}
