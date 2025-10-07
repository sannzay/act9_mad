import 'dart:math';
import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import 'animated_pulse.dart';

class SpookySprite extends StatefulWidget {
  final String imageAsset;
  final Offset basePos;       
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
    final dur = Duration(milliseconds: 2500 + _rng.nextInt(2500));
    _ctrl = AnimationController(vsync: this, duration: dur)..repeat();
    _ampX = 0.06 + _rng.nextDouble() * 0.12;
    _ampY = 0.04 + _rng.nextDouble() * 0.08;
    _phase = _rng.nextDouble() * pi * 2;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final baseX = widget.basePos.dx * w;
        final baseY = widget.basePos.dy * h;

        return AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) {
            final t = _ctrl.value * 2 * pi;
            final dx = sin(t + _phase) * _ampX * w;
            final dy = cos(t + _phase) * _ampY * h;
            final left = (baseX + dx) - widget.baseSize / 2;
            final top = (baseY + dy) - widget.baseSize / 2;

            return Positioned(
              left: left,
              top: top,
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
                child: SizedBox(
                  width: widget.baseSize,
                  height: widget.baseSize,
                  child: Column(
                    children: [
                      Expanded(
                        child: Hero(
                          tag: widget.isTarget
                              ? 'pumpkin-hero'
                              : 'sprite-${widget.basePos}',
                          child: Image.asset(widget.imageAsset,
                              width: widget.baseSize,
                              height: widget.baseSize,
                              fit: BoxFit.contain),
                        ),
                      ),
                      if (widget.isTarget)
                        AnimatedPulse(size: widget.baseSize * 0.8),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
