import 'package:cubebook/l10n/generated/L10n.dart';
import 'package:cubebook/theme/neo_colors.dart';
import 'package:flutter/material.dart';

class NotesTips extends StatelessWidget {
  const NotesTips({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = L10n.of(context);

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: NeoBrutalColors.cardColor(isDark),
          border: Border.all(
            width: 4,
            color: NeoBrutalColors.borderColor(isDark),
          ),
          boxShadow: NeoBrutalColors.adaptiveShadowMedium(isDark),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('o(TヘTo) ',
                style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
            const SizedBox(height: 16),
            Text(
              l10n.notesTips_1,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.notesTips_2,
              style: const TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
