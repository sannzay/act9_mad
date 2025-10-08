import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedPulse extends StatefulWidget {
  final double size;
  const AnimatedPulse({super.key, required this.size});

  @override
  State<AnimatedPulse> createState() => _AnimatedPulseState();
}

class _AnimatedPulseState extends State<AnimatedPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 1.5,
      height: widget.size * 1.5,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final t = _c.value;
          final scale = 0.8 + 0.4 * (1 + sin(t * 2 * 3.14159)) / 2;
          final alpha = 0.3 + 0.7 * (1 + sin(t * 2 * 3.14159)) / 2;
          
          return Center(
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orangeAccent.withOpacity(alpha * 0.8),
                      blurRadius: 20 * scale,
                      spreadRadius: 5 * scale,
                    ),
                    BoxShadow(
                      color: Colors.yellowAccent.withOpacity(alpha * 0.6),
                      blurRadius: 30 * scale,
                      spreadRadius: 10 * scale,
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.orangeAccent.withOpacity(alpha * 0.6),
                        Colors.yellowAccent.withOpacity(alpha * 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
