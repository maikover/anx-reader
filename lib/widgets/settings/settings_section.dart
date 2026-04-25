import 'package:cubebook/widgets/settings/settings_tile.dart';
import 'package:cubebook/theme/neo_colors.dart';
import 'package:flutter/material.dart';

abstract class AbstractSettingsSection extends StatelessWidget {
  const AbstractSettingsSection({super.key});
}

class SettingsSection extends AbstractSettingsSection {
  const SettingsSection({
    super.key,
    required this.tiles,
    this.margin,
    this.title,
  });

  final List<AbstractSettingsTile> tiles;
  final EdgeInsetsDirectional? margin;
  final Widget? title;

  @override
  Widget build(BuildContext context) {
    return buildSectionBody(context);
  }

  Widget buildSectionBody(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileList = buildTileList();

    if (title == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: _buildNeoContainer(
          context: context,
          child: tileList,
          isDark: isDark,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title with yellow highlight bar
          Padding(
            padding: const EdgeInsetsDirectional.only(
              top: 20,
              bottom: 0,
              start: 16,
              end: 16,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: NeoBrutalColors.adaptiveYellow(isDark),
                border: Border(
                  bottom: BorderSide(width: 4, color: NeoBrutalColors.borderColor(isDark)),
                  top: BorderSide(width: 4, color: NeoBrutalColors.borderColor(isDark)),
                  left: BorderSide(width: 4, color: NeoBrutalColors.borderColor(isDark)),
                  right: BorderSide(width: 4, color: NeoBrutalColors.borderColor(isDark)),
                ),
              ),
              child: DefaultTextStyle(
                style: TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                  color: NeoBrutalColors.borderColor(isDark),
                ),
                child: title!,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: _buildNeoContainer(
              context: context,
              child: tileList,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeoContainer({
    required BuildContext context,
    required Widget child,
    required bool isDark,
  }) {
    // Adaptive container with 4px border + hard shadow
    return Container(
      decoration: BoxDecoration(
        color: NeoBrutalColors.cardColor(isDark),
        border: Border.all(
          width: 4,
          color: NeoBrutalColors.borderColor(isDark),
        ),
        boxShadow: NeoBrutalColors.adaptiveShadowMedium(isDark),
      ),
      child: child,
    );
  }

  Widget buildTileList() {
    return Column(
      children: tiles,
    );
  }
}

class CustomSettingsSection extends AbstractSettingsSection {
  const CustomSettingsSection({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}