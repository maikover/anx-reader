import 'package:flutter/material.dart';
import 'neo_colors.dart';

/// Neo-brutalist Typography
class NeoTypography {
  NeoTypography._();

  static const String fontFamily = 'Space Grotesk';

  static TextStyle displayLarge(BuildContext context) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 96,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.02,
        height: 0.85,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle displayMedium(BuildContext context) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 60,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.02,
        height: 0.9,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle headlineLarge(BuildContext context) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 48,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.01,
        height: 1.0,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle headlineMedium(BuildContext context) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 36,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
        height: 1.1,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle titleLarge(BuildContext context) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.2,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle titleMedium(BuildContext context) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.01,
        height: 1.3,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle bodyLarge(BuildContext context) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.5,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle bodyMedium(BuildContext context) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.5,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle labelLarge(BuildContext context) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
        height: 1.4,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle labelMedium(BuildContext context) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.15,
        height: 1.4,
        color: Theme.of(context).colorScheme.onSurface,
      );
}

/// Neo-brutalist Theme Data builder
class NeoTheme {
  NeoTheme._();

  static ThemeData light({Color? themeColor, bool eInkMode = false}) {
    final primaryColor = themeColor ?? NeoBrutalColors.red;
    final bgColor = eInkMode ? Colors.white : NeoBrutalColors.cream;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: NeoTypography.fontFamily,
      scaffoldBackgroundColor: bgColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        onPrimary: NeoBrutalColors.white,
        secondary: NeoBrutalColors.yellow,
        onSecondary: NeoBrutalColors.ink,
        tertiary: NeoBrutalColors.violet,
        onTertiary: NeoBrutalColors.ink,
        surface: NeoBrutalColors.white,
        onSurface: NeoBrutalColors.ink,
        error: NeoBrutalColors.red,
        onError: NeoBrutalColors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgColor,
        foregroundColor: NeoBrutalColors.ink,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: NeoTypography.fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: NeoBrutalColors.ink,
          letterSpacing: 0.05,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: NeoBrutalColors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: NeoBrutalColors.ink,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: NeoBrutalColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: const BorderSide(
            width: 4,
            color: NeoBrutalColors.ink,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: NeoBrutalColors.white,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(
              width: 4,
              color: NeoBrutalColors.ink,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontFamily: NeoTypography.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: NeoBrutalColors.ink,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(
              width: 4,
              color: NeoBrutalColors.ink,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontFamily: NeoTypography.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: NeoBrutalColors.ink,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(
              width: 2,
              color: NeoBrutalColors.ink,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: NeoTypography.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NeoBrutalColors.white,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(
            width: 4,
            color: NeoBrutalColors.ink,
          ),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(
            width: 4,
            color: NeoBrutalColors.ink,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(
            width: 4,
            color: NeoBrutalColors.ink,
          ),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(
            width: 4,
            color: NeoBrutalColors.red,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(
          fontFamily: NeoTypography.fontFamily,
          fontWeight: FontWeight.w700,
          color: NeoBrutalColors.ink,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return NeoBrutalColors.white;
          }
          return NeoBrutalColors.ink;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return NeoBrutalColors.white;
        }),
        trackOutlineColor: WidgetStateProperty.all(NeoBrutalColors.ink),
      ),
      sliderTheme: SliderThemeData(
        thumbColor: primaryColor,
        activeTrackColor: primaryColor,
        inactiveTrackColor: NeoBrutalColors.white,
        overlayColor: primaryColor.withAlpha(41),
        trackHeight: 8,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: NeoBrutalColors.white,
      ),
      dividerTheme: const DividerThemeData(
        color: NeoBrutalColors.ink,
        thickness: 4,
        space: 0,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minVerticalPadding: 14,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: NeoBrutalColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: const BorderSide(
            width: 4,
            color: NeoBrutalColors.ink,
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: NeoBrutalColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(
            width: 4,
            color: NeoBrutalColors.ink,
          ),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: NeoBrutalColors.white,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: NeoBrutalColors.ink,
        contentTextStyle: const TextStyle(
          fontFamily: NeoTypography.fontFamily,
          fontWeight: FontWeight.w700,
          color: NeoBrutalColors.white,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(
            width: 4,
            color: NeoBrutalColors.ink,
          ),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData dark({Color? themeColor, bool oledMode = false}) {
    // In dark mode: cards/containers are WHITE with BLACK borders and black hard shadows.
    // This creates maximum neo-brutalist contrast on the dark background canvas.
    final primaryColor = themeColor ?? NeoBrutalColors.darkRed;
    final bgColor = oledMode ? Colors.black : NeoBrutalColors.darkBg;
    final surfaceColor = oledMode ? Colors.black : NeoBrutalColors.darkSurface;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: NeoTypography.fontFamily,
      scaffoldBackgroundColor: bgColor,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        onPrimary: NeoBrutalColors.white,
        secondary: NeoBrutalColors.darkYellow,
        onSecondary: NeoBrutalColors.ink,
        tertiary: NeoBrutalColors.darkViolet,
        onTertiary: NeoBrutalColors.ink,
        // dark-adapted surface color for comfortable contrast
        surface: surfaceColor,
        onSurface: NeoBrutalColors.white,
        error: NeoBrutalColors.darkRed,
        onError: NeoBrutalColors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgColor,
        foregroundColor: NeoBrutalColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: NeoTypography.fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: NeoBrutalColors.white,
          letterSpacing: 0.05,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: NeoBrutalColors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      // Cards in dark mode: darkSurface with darkBorder — comfortable contrast
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: const BorderSide(
            width: 4,
            color: NeoBrutalColors.darkBorder,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: NeoBrutalColors.white,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(
              width: 4,
              color: NeoBrutalColors.darkBorder,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontFamily: NeoTypography.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: NeoBrutalColors.white,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(
              width: 4,
              color: NeoBrutalColors.darkBorder,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontFamily: NeoTypography.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: NeoBrutalColors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(
              width: 2,
              color: NeoBrutalColors.darkBorder,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: NeoTypography.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(
            width: 4,
            color: NeoBrutalColors.darkBorder,
          ),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(
            width: 4,
            color: NeoBrutalColors.darkBorder,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(
            width: 4,
            color: NeoBrutalColors.darkBorder,
          ),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(
            width: 4,
            color: NeoBrutalColors.darkRed,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(
          fontFamily: NeoTypography.fontFamily,
          fontWeight: FontWeight.w700,
          color: NeoBrutalColors.darkBorder,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return NeoBrutalColors.white;
          }
          return NeoBrutalColors.darkBorder;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return surfaceColor;
        }),
        trackOutlineColor: WidgetStateProperty.all(NeoBrutalColors.darkBorder),
      ),
      sliderTheme: SliderThemeData(
        thumbColor: primaryColor,
        activeTrackColor: primaryColor,
        inactiveTrackColor: surfaceColor,
        overlayColor: primaryColor.withAlpha(41),
        trackHeight: 8,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: surfaceColor,
      ),
      dividerTheme: const DividerThemeData(
        color: NeoBrutalColors.darkBorder,
        thickness: 4,
        space: 0,
      ),
      listTileTheme: ListTileThemeData(
        tileColor: surfaceColor,
        textColor: NeoBrutalColors.white,
        iconColor: NeoBrutalColors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minVerticalPadding: 14,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: const BorderSide(
            width: 4,
            color: NeoBrutalColors.darkBorder,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(
            width: 4,
            color: NeoBrutalColors.darkBorder,
          ),
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: surfaceColor,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceColor,
        contentTextStyle: const TextStyle(
          fontFamily: NeoTypography.fontFamily,
          fontWeight: FontWeight.w700,
          color: NeoBrutalColors.white,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(
            width: 4,
            color: NeoBrutalColors.darkBorder,
          ),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}