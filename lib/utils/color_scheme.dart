import 'package:cubebook/config/shared_preference_provider.dart';
import 'package:cubebook/theme/neo_theme.dart';
import 'package:flutter/material.dart';

ThemeData colorSchema(
  Prefs prefsNotifier,
  BuildContext context,
  Brightness brightness,
) {
  print('DEBUG colorSchema: Received brightness=$brightness, themeMode=${prefsNotifier.themeMode}, eInkMode=${prefsNotifier.eInkMode}');
  brightness = prefsNotifier.eInkMode
      ? Brightness.light
      : switch (prefsNotifier.themeMode) {
          ThemeMode.light => Brightness.light,
          ThemeMode.dark => Brightness.dark,
          ThemeMode.system => MediaQuery.platformBrightnessOf(context),
        };

  final isDark = brightness == Brightness.dark;

  // Neo-brutalist theme - uses fixed high-saturation colors
  // Future: could make accent colors user-configurable within Neo palette
  return isDark ? NeoTheme.dark() : NeoTheme.light();
}