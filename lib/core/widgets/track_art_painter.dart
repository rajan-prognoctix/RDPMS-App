import 'package:flutter/material.dart';

/// Faint line art for navy headers: two soft rings, a signal post with three lamps,
/// and a track with sleepers along the bottom. Used on the splash and login screens.
class TrackArtPainter extends CustomPainter {
  /// Distance of the track from the bottom edge.
  final double trackBottomInset;

  const TrackArtPainter({this.trackBottomInset = 24});

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Soft rings, top right.
    canvas.drawCircle(Offset(size.width + 10, -10), 120, line);
    canvas.drawCircle(Offset(size.width + 10, -10), 170, line);

    // Track along the bottom.
    final railBottom = size.height - trackBottomInset;
    final railTop = railBottom - 10;
    canvas.drawLine(Offset(0, railTop), Offset(size.width, railTop), line);
    canvas.drawLine(Offset(0, railBottom), Offset(size.width, railBottom), line);
    for (double x = 8; x < size.width; x += 18) {
      canvas.drawLine(Offset(x, railTop - 4), Offset(x, railBottom + 4), line);
    }

    // Signal post, right side.
    final postX = size.width - 44;
    final headTop = size.height * 0.30;
    canvas.drawLine(Offset(postX, railTop - 4), Offset(postX, headTop + 66), line);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(postX - 13, headTop, 26, 66), const Radius.circular(13)),
      line,
    );
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(Offset(postX, headTop + 13 + i * 20.0), 6, line);
    }
  }

  @override
  bool shouldRepaint(covariant TrackArtPainter oldDelegate) =>
      oldDelegate.trackBottomInset != trackBottomInset;
}
