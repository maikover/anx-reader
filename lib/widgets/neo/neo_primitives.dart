import 'package:flutter/material.dart';
import 'package:cubebook/theme/neo_colors.dart';

/// Neo-brutalist container with hard shadows and thick borders
class NeoContainer extends StatelessWidget {
  const NeoContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.color,
    this.borderColor,
    this.shadowSize = NeoShadowSize.medium,
    this.rotateDegrees = 0,
    this.constraints,
  });

  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? borderColor;
  final NeoShadowSize shadowSize;
  final double rotateDegrees;
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Adaptive card color for dark mode comfort
    final backgroundColor = color ?? NeoBrutalColors.cardColor(isDark);

    final effectiveBorderColor = borderColor ?? NeoBrutalColors.borderColor(isDark);

    return Transform.rotate(
      angle: rotateDegrees * 3.14159 / 180,
      child: Container(
        width: width,
        height: height,
        constraints: constraints,
        margin: margin,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            width: 4,
            color: effectiveBorderColor,
          ),
          boxShadow: _getShadow(isDark),
        ),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }

  List<BoxShadow> _getShadow(bool isDark) {
    final shadowColor = borderColor ?? NeoBrutalColors.borderColor(isDark);
    switch (shadowSize) {
      case NeoShadowSize.small:
        return NeoBrutalColors.hardShadowSmall(color: shadowColor);
      case NeoShadowSize.medium:
        return NeoBrutalColors.hardShadowMedium(color: shadowColor);
      case NeoShadowSize.large:
        return NeoBrutalColors.hardShadowLarge(color: shadowColor);
      case NeoShadowSize.massive:
        return NeoBrutalColors.hardShadowMassive(color: shadowColor);
    }
  }
}

enum NeoShadowSize { small, medium, large, massive }

/// Neo-brutalist card with lift-on-hover effect
class NeoCard extends StatefulWidget {
  const NeoCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.color,
    this.shadowSize = NeoShadowSize.medium,
    this.onTap,
    this.rotateDegrees = 0,
  });

  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final NeoShadowSize shadowSize;
  final VoidCallback? onTap;
  final double rotateDegrees;

  @override
  State<NeoCard> createState() => _NeoCardState();
}

class _NeoCardState extends State<NeoCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Adaptive card color for dark mode comfort
    final backgroundColor = widget.color ?? NeoBrutalColors.cardColor(isDark);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.identity()
            ..translate(
              _isHovered ? -2.0 : 0.0,
              _isHovered ? -4.0 : 0.0,
            ),
          child: NeoContainer(
            width: widget.width,
            height: widget.height,
            padding: widget.padding,
            margin: widget.margin,
            color: backgroundColor,
            shadowSize: _isHovered
                ? _nextLargerShadow(widget.shadowSize)
                : widget.shadowSize,
            rotateDegrees: widget.rotateDegrees,
            child: widget.child,
          ),
        ),
      ),
    );
  }

  NeoShadowSize _nextLargerShadow(NeoShadowSize size) {
    switch (size) {
      case NeoShadowSize.small:
        return NeoShadowSize.medium;
      case NeoShadowSize.medium:
        return NeoShadowSize.large;
      case NeoShadowSize.large:
        return NeoShadowSize.massive;
      case NeoShadowSize.massive:
        return NeoShadowSize.massive;
    }
  }
}

/// Neo-brutalist button with push-down effect
class NeoButton extends StatefulWidget {
  const NeoButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = NeoButtonVariant.primary,
    this.size = NeoButtonSize.medium,
    this.fullWidth = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final NeoButtonVariant variant;
  final NeoButtonSize size;
  final bool fullWidth;

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor;
    Color textColor;
    Color borderColor = NeoBrutalColors.borderColor(isDark);

    switch (widget.variant) {
      case NeoButtonVariant.primary:
        bgColor = NeoBrutalColors.adaptiveRed(isDark);
        textColor = NeoBrutalColors.white;
        break;
      case NeoButtonVariant.secondary:
        bgColor = NeoBrutalColors.adaptiveYellow(isDark);
        textColor = isDark ? NeoBrutalColors.white : NeoBrutalColors.ink;
        break;
      case NeoButtonVariant.outline:
        bgColor = NeoBrutalColors.cardColor(isDark);
        textColor = isDark ? NeoBrutalColors.white : NeoBrutalColors.ink;
        break;
      case NeoButtonVariant.ghost:
        bgColor = Colors.transparent;
        textColor = isDark ? NeoBrutalColors.white : NeoBrutalColors.ink;
        borderColor = Colors.transparent;
        break;
    }

    double height;
    switch (widget.size) {
      case NeoButtonSize.small:
        height = 40;
        break;
      case NeoButtonSize.medium:
        height = 56;
        break;
      case NeoButtonSize.large:
        height = 72;
        break;
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          width: widget.fullWidth ? double.infinity : null,
          height: height,
          transform: Matrix4.identity()
            ..translate(
              _isPressed ? 2.0 : 0.0,
              _isPressed ? 4.0 : 0.0,
            ),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(
              width: 4,
              color: borderColor,
            ),
            boxShadow: _isPressed
                ? []
                : _getShadow(isDark),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: DefaultTextStyle(
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
                color: textColor,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }

  List<BoxShadow> _getShadow(bool isDark) {
    switch (widget.size) {
      case NeoButtonSize.small:
        return NeoBrutalColors.hardShadowSmall(color: NeoBrutalColors.borderColor(isDark));
      case NeoButtonSize.medium:
        return NeoBrutalColors.hardShadowMedium(color: NeoBrutalColors.borderColor(isDark));
      case NeoButtonSize.large:
        return NeoBrutalColors.hardShadowLarge(color: NeoBrutalColors.borderColor(isDark));
    }
  }
}

enum NeoButtonVariant { primary, secondary, outline, ghost }

enum NeoButtonSize { small, medium, large }

/// Neo-brutalist badge
class NeoBadge extends StatelessWidget {
  const NeoBadge({
    super.key,
    required this.child,
    this.color,
    this.rotateDegrees = 3,
  });

  final Widget child;
  final Color? color;
  final double rotateDegrees;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final badgeColor = color ?? NeoBrutalColors.adaptiveYellow(isDark);
    final borderAndTextColor = NeoBrutalColors.borderColor(isDark);

    return Transform.rotate(
      angle: rotateDegrees * 3.14159 / 180,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: badgeColor,
          border: Border.all(
            width: 3,
            color: borderAndTextColor,
          ),
          boxShadow: NeoBrutalColors.hardShadowSmall(color: borderAndTextColor),
        ),
        child: DefaultTextStyle(
          style: TextStyle(
            fontFamily: 'Space Grotesk',
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.15,
            color: borderAndTextColor,
          ),
          child: child,
        ),
      ),
    );
  }
}