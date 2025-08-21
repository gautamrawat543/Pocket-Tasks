import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/task_provider.dart';

class ProgressRing extends StatelessWidget {
  final double size;
  const ProgressRing({super.key, this.size = 60});

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TaskProvider>();
    final total = tp.totalCount;
    final done = tp.completedCount;
    final p = tp.progress;

    return CustomPaint(
      painter: _RingPainter(
          progress: p, isDark: Theme.of(context).brightness == Brightness.dark),
      child: SizedBox(
        height: size,
        width: size,
        child: Center(
          child: Text(
            "$done/$total",
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final bool isDark;
  _RingPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {  
    const stroke = 6.0;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide - stroke) / 2;

    final bg = Paint()
      ..color = isDark ? Colors.white24 : Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final fg = Paint()
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
        colors: const [Color(0xFF00E676), Color(0xFF64FFDA)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final arcRect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(arcRect, -pi / 2, 2 * pi, false, bg);
    canvas.drawArc(arcRect, -pi / 2, 2 * pi * progress, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.isDark != isDark;
}
