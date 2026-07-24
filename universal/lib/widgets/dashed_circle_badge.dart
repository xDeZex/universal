import 'dart:math';

import 'package:flutter/material.dart';

/// A circular, dashed-outline stand-in for [CircleAvatar], marking an
/// unfilled target row's set-number badge as not-yet-logged.
class DashedCircleBadge extends StatelessWidget {
  final Color color;

  const DashedCircleBadge({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(painter: DashedCirclePainter(color: color)),
    );
  }
}

/// Exposed (rather than kept private) so its `shouldRepaint` comparison can
/// be unit-tested directly instead of only indirectly through a widget pump.
@visibleForTesting
class DashedCirclePainter extends CustomPainter {
  final Color color;

  const DashedCirclePainter({required this.color});

  static const _dashCount = 10;
  static const _dashSweep = 2 * pi / _dashCount;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final arcRect = Rect.fromCircle(center: center, radius: radius - 1);
    for (var i = 0; i < _dashCount; i++) {
      canvas.drawArc(arcRect, i * _dashSweep, _dashSweep * 0.6, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color;
}
