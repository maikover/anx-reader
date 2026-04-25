import 'package:cubebook/theme/neo_colors.dart';
import 'package:flutter/material.dart';

/// Defines a single dropdown item used by [AnxDropdownButton].
class DropdownItem<T> {
  const DropdownItem({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final Widget? icon;
}

/// A thin wrapper around [DropdownButton] that provides consistent styling
/// and accepts [DropdownItem] definitions across the app.
class AnxDropdownButton<T> extends StatelessWidget {
  const AnxDropdownButton({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.isExpanded = true,
    this.hint,
    this.decoration,
    this.textStyle,
    this.enabled = true,
  });

  final List<DropdownItem<T>> items;
  final T value;
  final ValueChanged<T?>? onChanged;
  final bool isExpanded;
  final Widget? hint;
  final BoxDecoration? decoration;
  final TextStyle? textStyle;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: decoration ??
          BoxDecoration(
            color: isDark ? NeoBrutalColors.darkSurface : NeoBrutalColors.white,
            border: Border.all(width: 3, color: NeoBrutalColors.borderColor(isDark)),
          ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButton<T>(
        isDense: true,
        value: value,
        isExpanded: isExpanded,
        underline: const SizedBox.shrink(),
        hint: hint,
        icon: Icon(
          Icons.arrow_drop_down,
          color: NeoBrutalColors.borderColor(isDark),
        ),
        dropdownColor: isDark ? NeoBrutalColors.darkSurface : NeoBrutalColors.white,
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item.value,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.icon != null) ...[
                  item.icon!,
                  const SizedBox(width: 8),
                ],
                Text(
                  item.label,
                  style: TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontWeight: FontWeight.w700,
                    color: isDark ? NeoBrutalColors.white : NeoBrutalColors.ink,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: enabled ? onChanged : null,
      ),
    );
  }
}