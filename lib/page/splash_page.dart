import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashPage({super.key, required this.onComplete});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), widget.onComplete);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 24),
                    Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: _buildBookText(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLetterBox('C', const Color(0xFFFF6B6B)),
        _buildLetterBox('U', const Color(0xFFFFD93D)),
        _buildLetterBox('B', const Color(0xFFC4B5FD)),
        _buildLetterBox('E', const Color(0xFFFF6B6B)),
      ],
    );
  }

  Widget _buildLetterBox(String letter, Color color) {
    return Container(
      width: 70,
      height: 70,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(77),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(
            fontFamily: 'Space Grotesk',
            fontSize: 42,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildBookText() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFFFD93D), width: 3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'BOOK',
        style: TextStyle(
          fontFamily: 'Space Grotesk',
          fontSize: 36,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 8,
        ),
      ),
    );
  }
}
