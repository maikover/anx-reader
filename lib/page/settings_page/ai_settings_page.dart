import 'package:cubebook/page/settings_page/ai.dart';
import 'package:flutter/material.dart';
import 'package:cubebook/theme/neo_colors.dart';
import 'package:cubebook/l10n/generated/L10n.dart';

class AiSettingsPage extends StatelessWidget {
  const AiSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: NeoBrutalColors.cardColor(isDark),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: NeoBrutalColors.borderColor(isDark)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          L10n.of(context).settingsAi,
          style: TextStyle(color: NeoBrutalColors.borderColor(isDark)),
        ),
      ),
      body: const AISettings(),
    );
  }
}