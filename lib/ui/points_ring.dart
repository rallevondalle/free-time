import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Circular progress ring with the day's points in the middle.
class PointsRing extends StatelessWidget {
  const PointsRing({
    super.key,
    required this.points,
    required this.goal,
    required this.subtitle,
    required this.label,
    this.size = 240,
  });

  final int points;
  final int goal;
  final String subtitle;
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (points / goal).clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => CustomPaint(
              size: Size.square(size),
              painter: _RingPainter(
                progress: v,
                track: theme.colorScheme.surfaceContainerHigh,
                fill: theme.colorScheme.primary,
                glow: theme.colorScheme.secondary,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$points', style: theme.textTheme.displayLarge?.copyWith(fontSize: 64 * size / 240, height: 1)),
              const SizedBox(height: 4),
              Text(label, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 10),
              Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.track, required this.fill, required this.glow});
  final double progress;
  final Color track, fill, glow;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 16.0;
    final rect = Offset.zero & size;
    final r = rect.deflate(stroke / 2);
    canvas.drawArc(r, 0, math.pi * 2, false, Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke);
    if (progress <= 0) return;
    final sweep = math.pi * 2 * progress;
    canvas.drawArc(r, -math.pi / 2, sweep, false, Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: [fill, Color.lerp(fill, glow, 0.6)!],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
