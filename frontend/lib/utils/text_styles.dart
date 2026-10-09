import 'package:flutter/material.dart';

/// Custom text styles for KKB
/// Font: Plus Jakarta Sans (weights 400–800)
/// Colors are intentionally NOT set here because they change with light/dark mode.
/// Apply them with .copyWith(color: ...) or via the theme's DefaultTextStyle.
class KKBTextStyles {
  KKBTextStyles._(); // Prevent instantiation

  static const String fontFamily = 'PlusJakartaSans';

  // ============================================
  // DISPLAY STYLES (big amounts)
  // ============================================

  /// Amount entry on Add Expense
  static const TextStyle displayXLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 44,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.88,
    height: 1.0,
  );

  /// Net balance on Balances header card
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 40,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
    height: 1.0,
  );

  /// Expense total on Split Details
  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 38,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.76,
    height: 1.0,
  );

  /// Trip total spent on Settle Up
  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.72,
    height: 1.0,
  );

  /// Payment amount input on Settle Up
  static const TextStyle amountInput = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
    height: 1.0,
  );

  // ============================================
  // HEADER STYLES (screen titles)
  // ============================================

  /// "KKB" on Login
  static const TextStyle headerXLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.68,
    height: 1.2,
  );

  /// "Create your account"
  static const TextStyle headerLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
    height: 1.2,
  );

  /// "Groups", "Settings"
  static const TextStyle headerMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.56,
    height: 1.2,
  );

  /// "Add expense"
  static const TextStyle headerSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.52,
    height: 1.2,
  );

  /// "Split details"
  static const TextStyle headerXSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.48,
    height: 1.2,
  );

  static const TextStyle headerXXSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.44,
    height: 1.2,
  );

  // ============================================
  // TITLE STYLES (card / section titles)
  // ============================================

  /// Bottom sheet titles ("Join or create a group")
  static const TextStyle titleXLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.44,
    height: 1.2,
  );

  /// "Welcome back", expense name, profile name, favorite card balance
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.4,
    height: 1.2,
  );

  /// "Record a payment"
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.36,
    height: 1.2,
  );

  /// Section headings (Favorites, My groups), favorite card group name
  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.34,
    height: 1.2,
  );

  /// Sub-section headings ("Suggested payments", "Everyone's balance")
  static const TextStyle titleXSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.32,
    height: 1.2,
  );

  // ============================================
  // BUTTON STYLES
  // ============================================

  /// Primary CTA ("Sign in", "Add expense", "Record payment")
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
    height: 1.2,
  );

  /// Secondary buttons ("Continue with Google", "Join", "Edit profile")
  static const TextStyle buttonMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.2,
  );

  /// Segmented controls, small outline buttons
  static const TextStyle buttonSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.2,
  );

  /// "Remind", "Clear search"
  static const TextStyle buttonXSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.2,
  );

  // ============================================
  // BODY STYLES
  // ============================================

  // 15 - inputs, list item names, subtitles
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.35,
  );

  static const TextStyle bodyLargeBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.35,
  );

  static const TextStyle bodyLargeXBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
    height: 1.35,
  );

  // 14 - default body
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.35,
  );

  static const TextStyle bodyMediumSemiBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.35,
  );

  static const TextStyle bodyMediumBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.35,
  );

  static const TextStyle bodyMediumXBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
    height: 1.35,
  );

  // 13 - field labels, sublabels
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.35,
  );

  /// Field labels ("Email", "Amount")
  static const TextStyle bodySmallSemiBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.35,
  );

  static const TextStyle bodySmallBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.35,
  );

  // 12 - captions, helper text
  static const TextStyle bodyXSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.35,
  );

  static const TextStyle bodyXSmallSemiBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.35,
  );

  static const TextStyle bodyXSmallBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.35,
  );

  // ============================================
  // LABEL STYLES (nav, pills, avatars)
  // ============================================

  /// Bottom nav label (inactive)
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.2,
  );

  /// Bottom nav label (active)
  static const TextStyle labelSmallActive = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
    height: 1.2,
  );

  /// Note pills ("Rent due tomorrow", "Trip closed")
  static const TextStyle labelSmallBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.2,
  );

  /// Avatar initials in small avatars (scale 10–15 with avatar size, 26 for profile)
  static const TextStyle labelXSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
    height: 1.0,
  );

  /// Group join code input ("BORA-26")
  static const TextStyle code = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.92,
    height: 1.2,
  );
}