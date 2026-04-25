import 'package:cubebook/theme/neo_colors.dart';
import 'package:flutter/material.dart';

class DashboardMiniMetric extends StatelessWidget {
  const DashboardMiniMetric({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
  });

  final int value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fontSize = 14.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontFamily: 'Space Grotesk',
            color: isDark ? NeoBrutalColors.lightText : Colors.grey[600],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: 'Space Grotesk',
            color: isDark ? NeoBrutalColors.white : NeoBrutalColors.ink,
          ),
        ),
      ],
    );
  }
}