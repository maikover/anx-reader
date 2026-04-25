import 'package:cubebook/theme/neo_colors.dart';
import 'package:flutter/material.dart';

/// Neo-brutalist multi-colored logo for CubeBook
/// Each letter in "CUBE" has a different accent color, "BOOK" has a fixed color
/// that contrasts properly with dark backgrounds
class CubeBookLogo extends StatelessWidget {
  const CubeBookLogo({
    super.key,
    this.fontSize = 48,
  });

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final letterSpacing = fontSize * 0.05;
    final boxPadding = fontSize * 0.15;

    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        // C
        _buildLetter('C', NeoBrutalColors.red, -3, boxPadding, letterSpacing),
        // U
        _buildLetter('U', NeoBrutalColors.yellow, 1, boxPadding, letterSpacing),
        // B
        _buildLetter('B', NeoBrutalColors.violet, 2, boxPadding, letterSpacing),
        // E
        _buildLetter('E', NeoBrutalColors.red, -2, boxPadding, letterSpacing),
        // "BOOK" - white text on black for maximum contrast
        _buildLetter(
          'BOOK',
          NeoBrutalColors.ink, // black background
          0,
          boxPadding,
          letterSpacing,
          textColor: NeoBrutalColors.white, // white text!
        ),
      ],
    );
  }

  Widget _buildLetter(
    String text,
    Color color,
    double rotation,
    double boxPadding,
    double letterSpacing, {
    Color? textColor,
  }) {
    return Transform.rotate(
      angle: rotation * 3.14159 / 180,
      child: Container(
        margin: EdgeInsets.only(right: letterSpacing),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(width: 3, color: NeoBrutalColors.ink),
          boxShadow: NeoBrutalColors.hardShadowSmall(),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: boxPadding,
          vertical: boxPadding * 0.6,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Space Grotesk',
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.02,
            color: textColor ?? NeoBrutalColors.ink,
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// Compact horizontal logo for app bar
class CubeBookLogoCompact extends StatelessWidget {
  const CubeBookLogoCompact({
    super.key,
    this.height = 32,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? NeoBrutalColors.red : NeoBrutalColors.yellow,
        border: Border.all(width: 3, color: NeoBrutalColors.ink),
        boxShadow: NeoBrutalColors.hardShadowSmall(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // CUBE part with colored letters
          Text(
            'CUBE',
            style: TextStyle(
              fontFamily: 'Space Grotesk',
              fontSize: height * 0.55,
              fontWeight: FontWeight.w900,
              color: NeoBrutalColors.ink,
              letterSpacing: 1,
            ),
          ),
          Container(
            width: 3,
            height: height * 0.5,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            color: NeoBrutalColors.ink,
          ),
          // BOOK part - white on black
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            color: NeoBrutalColors.ink,
            child: Text(
              'BOOK',
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontSize: height * 0.55,
                fontWeight: FontWeight.w900,
                color: NeoBrutalColors.white,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Logo with shadow offset effect (classic Neo-brutalist pop)
/// CUBE letters with colors, BOOK in contrasting box
class CubeBookLogoPop extends StatelessWidget {
  const CubeBookLogoPop({
    super.key,
    this.fontSize = 60,
  });

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Shadow layer (offset)
        Transform.translate(
          offset: const Offset(8, 8),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: fontSize * 0.2,
              vertical: fontSize * 0.08,
            ),
            decoration: BoxDecoration(
              color: NeoBrutalColors.ink,
              border: Border.all(width: 4, color: NeoBrutalColors.ink),
            ),
            child: _buildLogoText(fontSize, NeoBrutalColors.darkBg),
          ),
        ),
        // Main text
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: fontSize * 0.2,
            vertical: fontSize * 0.08,
          ),
          decoration: BoxDecoration(
            color: NeoBrutalColors.yellow,
            border: Border.all(width: 4, color: NeoBrutalColors.ink),
            boxShadow: NeoBrutalColors.hardShadowMedium(),
          ),
          child: _buildLogoText(fontSize, NeoBrutalColors.ink),
        ),
      ],
    );
  }

  Widget _buildLogoText(double size, Color textColor) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ColoredLetter('C', NeoBrutalColors.red, textColor),
          const SizedBox(width: 2),
          _ColoredLetter('U', NeoBrutalColors.yellow, textColor),
          const SizedBox(width: 2),
          _ColoredLetter('B', NeoBrutalColors.violet, textColor),
          const SizedBox(width: 2),
          _ColoredLetter('E', NeoBrutalColors.red, textColor),
          const SizedBox(width: 8),
          _ColoredLetter('BOOK', NeoBrutalColors.ink, NeoBrutalColors.white),
        ],
      ),
    );
  }
}

class _ColoredLetter extends StatelessWidget {
  const _ColoredLetter(this.letter, this.bgColor, this.textColor);

  final String letter;
  final Color bgColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(width: 3, color: NeoBrutalColors.ink),
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontFamily: 'Space Grotesk',
          fontSize: sizeForLetter(letter),
          fontWeight: FontWeight.w900,
          color: textColor,
        ),
      ),
    );
  }

  double sizeForLetter(String letter) {
    // BOOK is longer, use slightly smaller font
    if (letter == 'BOOK') return 36;
    return 40;
  }
}