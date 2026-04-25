import 'package:cubebook/config/shared_preference_provider.dart';
import 'package:cubebook/theme/neo_colors.dart';
import 'package:cubebook/widgets/common/container/base_rounded_container.dart';
import 'package:cubebook/widgets/common/container/outlined_container.dart';
import 'package:flutter/material.dart';

class FilledContainer extends BaseRoundedContainer {
  const FilledContainer({
    super.key,
    required super.child,
    super.width,
    super.height,
    super.padding,
    super.margin,
    this.color,
    this.fill = false,
    super.radius,
    super.constraints,
    super.animationDuration,
    super.animationCurve,
    this.useNeoStyle = true,
  });

  final Color? color;
  final bool fill;
  final bool useNeoStyle;

  @override
  Widget build(BuildContext context) {
    if (Prefs().eInkMode && !fill) {
      return OutlinedContainer(
        width: width,
        height: height,
        padding: padding,
        margin: margin,
        radius: radius,
        constraints: constraints,
        animationDuration: animationDuration,
        animationCurve: animationCurve,
        child: child,
      );
    }

    return super.build(context);
  }

  @override
  ShapeDecoration decoration(
    BuildContext context,
    BorderRadiusGeometry borderRadius,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (useNeoStyle) {
      // Use passed color if provided, otherwise use adaptive card color
      final effectiveColor = color ?? NeoBrutalColors.cardColor(isDark);

      return ShapeDecoration(
        color: effectiveColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(
            width: 4,
            color: NeoBrutalColors.borderColor(isDark),
          ),
        ),
        shadows: NeoBrutalColors.adaptiveShadowMedium(isDark),
      );
    }

    final Color effectiveColor =
        color ?? Theme.of(context).colorScheme.surfaceContainer;

    return buildShapeDecoration(
      color: effectiveColor,
      borderSide: const BorderSide(
          color: Colors.transparent,
          width: 1,
          strokeAlign: BorderSide.strokeAlignOutside),
      borderRadius: borderRadius,
    );
  }
}