// lib/widgets/spooky_sprite.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import 'animated_pulse.dart';

/// This version DOES NOT return a Positioned. Instead it uses Align + Transform
/// so it can be safely used anywhere (Stack or non-Stack) without ParentData errors.
class SpookySprite extends StatefulWidget {
  final String imageAsset;
  final Offset basePos; // fractional (0..1)
  final double baseSize;
  final bool isTrap;
  final bool isTarget;
  final VoidCallback onFoundTarget;
  final VoidCallback onTriggeredTrap;

  const SpookySprite({
    super.key,
    required this.imageAsset,
    required this.basePos,
    required this.baseSize,
    required this.isTrap,
    required this.isTarget,
    required this.onFoundTarget,
    required this.onTriggeredTrap,
  });

  @override
  State<SpookySprite> createState() => _SpookySpriteState();
}

class _SpookySpriteState extends State<SpookySprite>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final double _ampX;
  late final double _ampY;
  late final double _phase;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    final dur = Duration(milliseconds: 2400 + _rng.nextInt(2600));
    _ctrl = AnimationController(vsync: this, duration: dur)..repeat();
    _ampX = 0.04 + _rng.nextDouble() * 0.10; // fraction of width
    _ampY = 0.03 + _rng.nextDouble() * 0.06; // fraction of height
    _phase = _rng.nextDouble() * pi * 2;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Convert basePos (0..1, 0..1) to Alignment (-1..1, -1..1)
  Alignment _alignmentFromFractional(Offset p) {
    return Alignment(p.dx * 2 - 1, p.dy * 2 - 1);
  }

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder only so we can compute pixel amplitude from parent size
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;

      // Avoid degenerate sizes
      final pixelAmpX = _ampX * max(1.0, w);
      final pixelAmpY = _ampY * max(1.0, h);

      return AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          final t = _ctrl.value * 2 * pi;
          final dx = sin(t + _phase) * pixelAmpX;
          final dy = cos(t + _phase * 1.1) * pixelAmpY;

          // Alignment places the center of the sprite at the fractional position.
          final alignment = _alignmentFromFractional(widget.basePos);

          // clamp translation so sprite stays on-screen (approximate)
          // compute rough left/top from alignment fraction:
          final approxCenterX = (widget.basePos.dx) * w;
          final approxCenterY = (widget.basePos.dy) * h;
          final minLeft = widget.baseSize / 2;
          final maxLeft = max(0.0, w - widget.baseSize / 2);
          final minTop = widget.baseSize / 2;
          final maxTop = max(0.0, h - widget.baseSize / 2);

          double centerX = (approxCenterX + dx).clamp(minLeft, maxLeft);
          double centerY = (approxCenterY + dy).clamp(minTop, maxTop);

          // final translate to apply relative to Align's center:
          final finalDx = centerX - approxCenterX;
          final finalDy = centerY - approxCenterY;

          return Align(
            alignment: alignment,
            child: Transform.translate(
              offset: Offset(finalDx, finalDy),
              child: SizedBox(
                width: widget.baseSize,
                height: widget.baseSize,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () async {
                    if (widget.isTrap) {
                      widget.onTriggeredTrap();
                    } else if (widget.isTarget) {
                      widget.onFoundTarget();
                    } else {
                      await AudioService.playSfx('success.mp3');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Not it — keep looking!'),
                          duration: Duration(milliseconds: 700),
                        ),
                      );
                    }
                  },
                  child: Stack(
                    children: [
                      // Glow effect behind the sprite (only for target)
                      if (widget.isTarget)
                        Positioned.fill(
                          child: AnimatedPulse(size: widget.baseSize * 1.2),
                        ),
                      // The actual sprite image
                      Center(
                        child: Hero(
                          tag:
                              widget.isTarget ? 'pumpkin-hero' : 'sprite-${widget.basePos}',
                          child: Image.asset(
                            widget.imageAsset,
                            width: widget.baseSize,
                            height: widget.baseSize,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
