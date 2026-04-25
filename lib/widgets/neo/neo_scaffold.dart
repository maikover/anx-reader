import 'package:cubebook/theme/neo_colors.dart';
import 'package:cubebook/widgets/neo/neo_background.dart';
import 'package:flutter/material.dart';

/// Neo-brutalist scaffold with textured background.
/// Wraps Scaffold and applies a solid color + pattern overlay.
class NeoScaffold extends StatelessWidget {
  const NeoScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.pattern = NeoBackgroundPattern.halftone,
    this.patternOpacity = 0.05,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final NeoBackgroundPattern pattern;
  final double patternOpacity;
  final bool extendBody;
  final bool extendBodyBehindAppBar;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NeoBackground(
      pattern: pattern,
      opacity: patternOpacity,
      color: isDark ? NeoBrutalColors.white : NeoBrutalColors.ink,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        bottomNavigationBar: bottomNavigationBar,
        extendBody: extendBody,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
      ),
    );
  }
}
