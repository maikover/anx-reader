import 'package:flutter/material.dart';

/// Neo-brutalist color palette
/// Based on the Neo-brutalism design system
class NeoBrutalColors {
  NeoBrutalColors._();

  // Light Mode Colors
  static const Color cream = Color(0xFFFFFDF5);
  static const Color ink = Color(0xFF000000);
  static const Color red = Color(0xFFFF6B6B);
  static const Color yellow = Color(0xFFFFD93D);
  static const Color violet = Color(0xFFC4B5FD);
  static const Color white = Color(0xFFFFFFFF);

  // Dark Mode Colors
  static const Color darkBg = Color(0xFF1a1a1a);
  static const Color darkSurface = Color(0xFF2a2a2a);
  static const Color darkBorder = Color(0xFF888888); // Medium gray for comfortable dark contrast

  /// Dark-adapted accent colors (~30% dimmed for low-light comfort)
  static const Color darkRed = Color(0xFFCC5555);
  static const Color darkYellow = Color(0xFFCCB030);
  static const Color darkViolet = Color(0xFF9A8FD9);

  // Text on dark backgrounds
  static const Color darkSecondaryText = Color(0xFFB0B0B0);

  /// In dark mode, cards use darkSurface for comfortable contrast.
  static const Color darkCard = Color(0xFF2a2a2a);

  // Text on dark backgrounds
  static const Color lightText = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF000000);

  // Shadows — always hard-edged, zero blur
  static List<BoxShadow> hardShadowSmall({Color color = ink}) => [
        BoxShadow(
          offset: const Offset(4, 4),
          blurRadius: 0,
          color: color,
        ),
      ];

  static List<BoxShadow> hardShadowMedium({Color color = ink}) => [
        BoxShadow(
          offset: const Offset(8, 8),
          blurRadius: 0,
          color: color,
        ),
      ];

  static List<BoxShadow> hardShadowLarge({Color color = ink}) => [
        BoxShadow(
          offset: const Offset(12, 12),
          blurRadius: 0,
          color: color,
        ),
      ];

  static List<BoxShadow> hardShadowMassive({Color color = ink}) => [
        BoxShadow(
          offset: const Offset(16, 16),
          blurRadius: 0,
          color: color,
        ),
      ];

  /// White hard shadow — use for elements that sit on dark backgrounds
  static List<BoxShadow> hardShadowWhiteSmall() => hardShadowSmall(color: white);
  static List<BoxShadow> hardShadowWhiteMedium() => hardShadowMedium(color: white);
  static List<BoxShadow> hardShadowWhiteLarge() => hardShadowLarge(color: white);

  /// Dark hard shadow — use for dark mode elements
  static List<BoxShadow> hardShadowDarkSmall() => hardShadowSmall(color: darkBorder);
  static List<BoxShadow> hardShadowDarkMedium() => hardShadowMedium(color: darkBorder);
  static List<BoxShadow> hardShadowDarkLarge() => hardShadowLarge(color: darkBorder);

  // Border sides
  static BorderSide borderDefault({Color? color}) => BorderSide(
        width: 4,
        color: color ?? ink,
      );

  static BorderSide borderThick({Color? color}) => BorderSide(
        width: 8,
        color: color ?? ink,
      );

  static BorderSide borderThin({Color? color}) => BorderSide(
        width: 2,
        color: color ?? ink,
      );

  /// Returns the appropriate card container color based on brightness.
  /// In dark mode this returns darkSurface for comfortable contrast.
  static Color cardColor(bool isDark) => isDark ? darkSurface : white;

  /// Returns the appropriate border/shadow color based on brightness.
  /// In dark mode uses medium gray (#888888) for comfortable contrast.
  static Color borderColor(bool isDark) => isDark ? darkBorder : ink;

  /// Returns the right hard-shadow based on brightness.
  static List<BoxShadow> adaptiveShadowSmall(bool isDark) =>
      isDark ? hardShadowDarkSmall() : hardShadowSmall();

  /// Returns the right hard-shadow based on brightness.
  static List<BoxShadow> adaptiveShadowMedium(bool isDark) =>
      isDark ? hardShadowDarkMedium() : hardShadowMedium();

  /// Returns the right hard-shadow based on brightness (large variant).
  static List<BoxShadow> adaptiveShadowLarge(bool isDark) =>
      isDark ? hardShadowDarkLarge() : hardShadowLarge();

  /// Returns the appropriate accent color based on brightness.
  static Color adaptiveRed(bool isDark) => isDark ? darkRed : red;
  static Color adaptiveYellow(bool isDark) => isDark ? darkYellow : yellow;
  static Color adaptiveViolet(bool isDark) => isDark ? darkViolet : violet;
}

/// Extension to easily access Neo colors from BuildContext
extension NeoColorsExtension on BuildContext {
  Color get neoCream => NeoBrutalColors.cream;
  Color get neoInk => NeoBrutalColors.ink;
  Color get neoRed => NeoBrutalColors.red;
  Color get neoYellow => NeoBrutalColors.yellow;
  Color get neoViolet => NeoBrutalColors.violet;
  Color get neoWhite => NeoBrutalColors.white;
  Color get neoDarkBg => NeoBrutalColors.darkBg;
  Color get neoDarkSurface => NeoBrutalColors.darkSurface;
  Color get neoDarkCard => NeoBrutalColors.darkCard;

  bool get isDarkMode =>
      Theme.of(this).brightness == Brightness.dark;

  /// Adaptive card color — white in both light and dark mode
  Color get neoCardColor => NeoBrutalColors.cardColor(isDarkMode);

  /// Adaptive border/shadow color — black in light, white in dark
  Color get neoBorderColor => NeoBrutalColors.borderColor(isDarkMode);
}