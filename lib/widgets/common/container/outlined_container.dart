import 'package:cubebook/theme/neo_colors.dart';
import 'package:cubebook/widgets/common/container/base_rounded_container.dart';
import 'package:flutter/material.dart';

class OutlinedContainer extends BaseRoundedContainer {
  const OutlinedContainer({
    super.key,
    required super.child,
    super.width,
    super.height,
    super.padding,
    super.margin,
    super.radius,
    super.constraints,
    super.animationDuration,
    super.animationCurve,
    this.color,
    this.outlineColor,
  });

  final Color? color;
  final Color? outlineColor;

  @override
  ShapeDecoration decoration(
    BuildContext context,
    BorderRadiusGeometry borderRadius,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return buildShapeDecoration(
      color: color ?? NeoBrutalColors.cardColor(isDark),
      borderSide: BorderSide(
          color: outlineColor ?? NeoBrutalColors.borderColor(isDark),
          width: 4,
          strokeAlign: BorderSide.strokeAlignOutside),
      borderRadius: borderRadius,
    );
  }
}
