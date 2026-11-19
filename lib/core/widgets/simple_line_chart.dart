import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ChartThreshold {
  final double value;
  final String label;
  final Color color;
  const ChartThreshold(this.value, this.label, this.color);
}

/// Dependency-free line chart for telemetry (Annex E/G "Graph" view).
class SimpleLineChart extends StatelessWidget {
  final List<double> values;
  final Color color;
  final String unit;
  final List<ChartThreshold> thresholds;
  final double height;

  const SimpleLineChart({
    super.key,
    required this.values,
    this.color = AppColors.primary,
    this.unit = '',
    this.thresholds = const [],
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _LinePainter(values, color, unit, thresholds)),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final String unit;
  final List<ChartThreshold> thresholds;

  _LinePainter(this.values, this.color, this.unit, this.thresholds);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    const left = 36.0, bottom = 18.0, top = 8.0;
    final w = size.width - left - 4;
    final h = size.height - bottom - top;

    final all = [...values, ...thresholds.map((t) => t.value)];
    var minV = all.reduce(math.min);
    var maxV = all.reduce(math.max);
    if (maxV == minV) maxV = minV + 1;
    final pad = (maxV - minV) * 0.1;
    minV -= pad;
    maxV += pad;

    double y(double v) => top + h - (v - minV) / (maxV - minV) * h;
    double x(int i) => left + (values.length == 1 ? 0 : i / (values.length - 1) * w);

    final grid = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    final textStyle = const TextStyle(fontSize: 9, color: Colors.black54);
    for (var i = 0; i <= 4; i++) {
      final v = minV + (maxV - minV) * i / 4;
      final yy = y(v);
      canvas.drawLine(Offset(left, yy), Offset(size.width, yy), grid);
      final tp = TextPainter(
        text: TextSpan(text: v.toStringAsFixed(v.abs() < 10 ? 1 : 0), style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, yy - tp.height / 2));
    }

    for (final t in thresholds) {
      final p = Paint()
        ..color = t.color
        ..strokeWidth = 1.2;
      final yy = y(t.value);
      for (var dx = left; dx < size.width; dx += 8) {
        canvas.drawLine(Offset(dx, yy), Offset(math.min(dx + 4, size.width), yy), p);
      }
      final tp = TextPainter(
        text: TextSpan(text: t.label, style: TextStyle(fontSize: 9, color: t.color)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(size.width - tp.width - 2, yy - tp.height - 1));
    }

    final path = Path()..moveTo(x(0), y(values[0]));
    for (var i = 1; i < values.length; i++) {
      path.lineTo(x(i), y(values[i]));
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    final unitTp = TextPainter(
      text: TextSpan(text: unit, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    unitTp.paint(canvas, Offset(0, size.height - unitTp.height));
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) => old.values != values;
}
