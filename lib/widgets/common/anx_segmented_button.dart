import 'package:cubebook/theme/neo_colors.dart';
import 'package:flutter/material.dart';

/// Defines a single segment item used by [AnxSegmentedButton].
class SegmentButtonItem<T> {
  const SegmentButtonItem({
    required this.value,
    required this.label,
    this.icon,
    this.labelStyle,
    this.maxLines,
    this.overflow,
  });

  final T value;
  final String label;
  final Widget? icon;
  final TextStyle? labelStyle;
  final int? maxLines;
  final TextOverflow? overflow;
}

/// A thin wrapper around [SegmentedButton] that accepts [SegmentButtonItem]
/// definitions to keep segment construction consistent across the app.
class AnxSegmentedButton<T> extends StatelessWidget {
  const AnxSegmentedButton({
    super.key,
    required this.segments,
    required this.selected,
    this.onSelectionChanged,
    this.multiSelectionEnabled = false,
    this.emptySelectionAllowed = false,
    this.showSelectedIcon = true,
    this.enabled = true,
    this.style,
  });

  final List<SegmentButtonItem<T>> segments;
  final Set<T> selected;
  final ValueChanged<Set<T>>? onSelectionChanged;
  final bool multiSelectionEnabled;
  final bool emptySelectionAllowed;
  final bool showSelectedIcon;
  final ButtonStyle? style;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SegmentedButton<T>(
      segments: segments
          .map(
            (segment) => ButtonSegment<T>(
              enabled: enabled,
              value: segment.value,
              label: Text(
                segment.label,
                softWrap: false,
                style: TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                maxLines: segment.maxLines ?? 1,
                overflow: segment.overflow ?? TextOverflow.fade,
              ),
              icon: segment.icon,
            ),
          )
          .toList(),
      selected: selected,
      onSelectionChanged: onSelectionChanged,
      multiSelectionEnabled: multiSelectionEnabled,
      emptySelectionAllowed: emptySelectionAllowed,
      showSelectedIcon: showSelectedIcon,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return NeoBrutalColors.adaptiveRed(isDark);
          }
          return NeoBrutalColors.cardColor(isDark);
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return NeoBrutalColors.white;
          }
          return NeoBrutalColors.borderColor(isDark);
        }),
        side: WidgetStateProperty.all(
          BorderSide(
            width: 3,
            color: NeoBrutalColors.borderColor(isDark),
          ),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }
}