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
      width: widget.size,
      height: widget.size / 4,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final t = (_c.value * 2) % 1.0;
          final alpha =
              (0.35 + 0.65 * (1 - (t - 0.5).abs() * 2)).clamp(0.0, 1.0);
          return Opacity(
            opacity: alpha,
            child: Container(
              width: widget.size,
              height: widget.size / 6,
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }
}
