import 'dart:math';

import 'package:cubebook/theme/neo_colors.dart';
import 'package:flutter/material.dart';

/// Neo-brutalist textured background widget
/// Provides halftone dots, grid pattern, or noise texture backgrounds
class NeoBackground extends StatelessWidget {
  const NeoBackground({
    super.key,
    required this.child,
    this.pattern = NeoBackgroundPattern.halftone,
    this.opacity = 0.05,
    this.color,
  });

  final Widget child;
  final NeoBackgroundPattern pattern;
  final double opacity;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // In light: use ink (black) dots; in dark: use white dots for visibility
    final effectiveColor = color ?? (isDark ? NeoBrutalColors.white : NeoBrutalColors.ink);

    return Stack(
      children: [
        // Background color
        Container(
          color: isDark ? NeoBrutalColors.darkBg : NeoBrutalColors.cream,
        ),
        // Pattern overlay
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _NeoPatternPainter(
                pattern: pattern,
                color: effectiveColor.withAlpha((opacity * 255).toInt()),
              ),
            ),
          ),
        ),
        // Content
        child,
      ],
    );
  }
}

enum NeoBackgroundPattern { halftone, grid, noise, mesh, none }

class _NeoPatternPainter extends CustomPainter {
  _NeoPatternPainter({
    required this.pattern,
    required this.color,
  });

  final NeoBackgroundPattern pattern;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (pattern) {
      case NeoBackgroundPattern.halftone:
        _paintHalftone(canvas, size, paint);
        break;
      case NeoBackgroundPattern.grid:
        _paintGrid(canvas, size, paint);
        break;
      case NeoBackgroundPattern.noise:
        _paintNoise(canvas, size, paint);
        break;
      case NeoBackgroundPattern.mesh:
        _paintMesh(canvas, size, paint);
        break;
      case NeoBackgroundPattern.none:
        break;
    }
  }

  void _paintHalftone(Canvas canvas, Size size, Paint paint) {
    const dotSpacing = 20.0;
    const dotRadius = 1.5;

    for (double y = 0; y < size.height; y += dotSpacing) {
      for (double x = 0; x < size.width; x += dotSpacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  void _paintGrid(Canvas canvas, Size size, Paint paint) {
    const gridSize = 40.0;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;

    // Vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _paintNoise(Canvas canvas, Size size, Paint paint) {
    // Seed-based random for consistent noise pattern
    final seed = (size.width.toInt() * 13 + size.height.toInt() * 17) % 1000;
    var rng = Random(seed);
    const density = 0.15; // 15% of canvas will have noise dots
    final totalDots = (size.width * size.height * density / 4).toInt();

    paint.style = PaintingStyle.fill;

    for (int i = 0; i < totalDots; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final dotSize = 1.0 + rng.nextDouble() * 2.0;
      canvas.drawRect(Rect.fromLTWH(x, y, dotSize, dotSize), paint);
    }
  }

  void _paintMesh(Canvas canvas, Size size, Paint paint) {
    // Dot grid pattern - like a mesh/maya of points
    const dotSpacing = 24.0;
    const dotRadius = 2.0;

    paint.style = PaintingStyle.fill;

    for (double y = dotSpacing / 2; y < size.height; y += dotSpacing) {
      for (double x = dotSpacing / 2; x < size.width; x += dotSpacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _NeoPatternPainter oldDelegate) {
    return oldDelegate.pattern != pattern || oldDelegate.color != color;
  }
}

/// Neo-brutalist section divider with color blocking
class NeoSectionDivider extends StatelessWidget {
  const NeoSectionDivider({
    super.key,
    this.color,
    this.height = 8,
  });

  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: height,
      color: color ?? NeoBrutalColors.adaptiveYellow(isDark),
      child: Stack(
        children: [
          // Shadow line
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 4,
              color: NeoBrutalColors.borderColor(isDark),
            ),
          ),
        ],
      ),
    );
  }
}

/// Neo-brutalist filter chip with press effect
class NeoFilterChip extends StatefulWidget {
  const NeoFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  State<NeoFilterChip> createState() => _NeoFilterChipState();
}

class _NeoFilterChipState extends State<NeoFilterChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = widget.color ?? NeoBrutalColors.adaptiveRed(isDark);
    final bgColor = widget.selected
        ? baseColor
        : NeoBrutalColors.cardColor(isDark);
    final borderAndTextColor = NeoBrutalColors.borderColor(isDark);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        // ignore: deprecated_member_use
        transform: Matrix4.identity()
          ..translate(
            _isPressed ? 2.0 : 0.0,
            _isPressed ? 3.0 : 0.0,
          ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            width: 3,
            color: borderAndTextColor,
          ),
          boxShadow: _isPressed
              ? []
              : [BoxShadow(offset: const Offset(4, 4), blurRadius: 0, color: borderAndTextColor)],
        ),
        child: Text(
          widget.label.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Space Grotesk',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
            color: borderAndTextColor,
          ),
        ),
      ),
    );
  }
}

/// Neo-brutalist icon button with push effect
class NeoIconButton extends StatefulWidget {
  const NeoIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 48,
    this.color,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final Color? color;
  final Color? iconColor;

  @override
  State<NeoIconButton> createState() => _NeoIconButtonState();
}

class _NeoIconButtonState extends State<NeoIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Adaptive icon button color
    final bgColor = widget.color ?? NeoBrutalColors.cardColor(isDark);
    final borderAndIconColor = widget.iconColor ?? NeoBrutalColors.borderColor(isDark);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.size,
        height: widget.size,
        transform: Matrix4.identity()
          // ignore: deprecated_member_use
          ..translate(
            _isPressed ? 2.0 : 0.0,
            _isPressed ? 3.0 : 0.0,
          ),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(width: 3, color: borderAndIconColor),
          boxShadow: _isPressed
              ? []
              : [BoxShadow(offset: const Offset(4, 4), blurRadius: 0, color: borderAndIconColor)],
        ),
        child: Center(
          child: Icon(
            widget.icon,
            size: widget.size * 0.5,
            color: borderAndIconColor,
          ),
        ),
      ),
    );
  }
}