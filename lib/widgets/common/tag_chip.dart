import 'package:cubebook/config/shared_preference_provider.dart';
import 'package:cubebook/l10n/generated/L10n.dart';
import 'package:cubebook/widgets/common/color_picker_sheet.dart';
import 'package:cubebook/widgets/delete_confirm.dart';
import 'package:flutter/material.dart';
import 'package:cubebook/utils/color/hash_color.dart';

class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.label,
    this.color,
    this.selected = false,
    this.onTap,
    this.onLongPress,
    this.dense = false,
  });

  final String label;
  final Color? color;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool dense;

  Color _colorForLabel(String value) {
    return color ?? hashColor(value);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final isEink = Prefs().eInkMode;

    final einkBgColor =
        selected ? theme.colorScheme.secondary : Colors.transparent;
    final einkBorderColor =
        selected ? Colors.transparent : theme.colorScheme.onSurface;
    final einkForeground =
        selected ? theme.colorScheme.onSecondary : theme.colorScheme.onSurface;

    final baseColor = _colorForLabel(label);
    final normalBgColor =
        selected ? baseColor.withAlpha(46) : Colors.transparent;
    final normalBorderColor =
        selected ? Colors.transparent : baseColor.withAlpha(102);
    final normalForeground = selected
        ? baseColor
        : Theme.of(context).colorScheme.onSurface.withAlpha(179);

    final bgColor = isEink ? einkBgColor : normalBgColor;
    final normalBborderColor = isEink ? einkBorderColor : normalBorderColor;
    final foreground = isEink ? einkForeground : normalForeground;

    return InkWell(
      borderRadius: BorderRadius.zero,
      onTap: onTap,
      onLongPress: onLongPress,
      onSecondaryTap: onLongPress,
      child: Container(
        padding: dense
            ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? baseColor : Colors.transparent,
          borderRadius: BorderRadius.zero,
          border: Border.all(color: baseColor, width: 2),
        ),
        child: Text(
          '# $label',
          style: TextStyle(
            fontFamily: 'Space Grotesk',
            fontWeight: FontWeight.w700,
            fontSize: dense ? 11 : 13,
            color: selected ? Colors.white : baseColor,
          ),
        ),
      ),
    );
  }

  static Future<void> showEditDialog({
    required BuildContext context,
    required String initialName,
    required Color? initialColor, // RGB
    required Future<void> Function(String newName) onRename,
    required Future<void> Function(Color color) onColorChange,
    required Future<void> Function() onDelete,
  }) async {
    final l10n = L10n.of(context);
    final controller = TextEditingController(text: initialName);
    await showDialog(
      context: context,
      builder: (dialogContext) {
        Color colorValue =
            (initialColor ?? hashColor(initialName)).withAlpha(0xFF);
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.tagEditTitle),
                  DeleteConfirm(delete: () async {
                    await onDelete();
                    if (context.mounted) Navigator.of(dialogContext).pop();
                  }),
                ],
              ),
              content: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: l10n.tagNamePlaceholder,
                ),
              ),
              actions: [
                IconButton(
                  tooltip: l10n.tagColorTooltip,
                  icon: Icon(Icons.circle, color: colorValue),
                  onPressed: () async {
                    final picked = await showRgbColorPicker(
                      context: context,
                      initialColor: colorValue,
                    );
                    if (picked != null) {
                      setStateDialog(() {
                        colorValue = picked;
                      });
                      await onColorChange(colorValue);
                    }
                  },
                ),
                TextButton(
                  onPressed: () async {
                    final newName = controller.text.trim();
                    if (newName.isEmpty) return;
                    await onRename(newName);
                    if (context.mounted) Navigator.of(dialogContext).pop();
                  },
                  child: Text(l10n.commonSave),
                ),
              ],
            );
          },
        );
      },
    );
    controller.dispose();
  }
}
