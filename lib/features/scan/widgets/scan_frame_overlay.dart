import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ScanFrameOverlay extends StatefulWidget {
  const ScanFrameOverlay({super.key});

  @override
  State<ScanFrameOverlay> createState() => _ScanFrameOverlayState();
}

class _ScanFrameOverlayState extends State<ScanFrameOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return CustomPaint(
          painter: _FramePainter(opacity: _animation.value),
          child: Container(),
        );
      },
    );
  }
}

class _FramePainter extends CustomPainter {
  final double opacity;
  _FramePainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.tealBright.withOpacity(opacity)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const frameSize = 250.0;
    const cornerLength = 40.0;
    const cornerRadius = 8.0;

    final left = (size.width - frameSize) / 2;
    final top = (size.height - frameSize) / 2;
    final right = left + frameSize;
    final bottom = top + frameSize;

    // Top-left corner
    canvas.drawLine(
        Offset(left + cornerRadius, top), Offset(left + cornerLength, top), paint);
    canvas.drawLine(
        Offset(left, top + cornerRadius), Offset(left, top + cornerLength), paint);
    canvas.drawArc(
        Rect.fromLTWH(left, top, cornerRadius * 2, cornerRadius * 2),
        -3.14,
        -1.57,
        false,
        paint);

    // Top-right corner
    canvas.drawLine(
        Offset(right - cornerLength, top), Offset(right - cornerRadius, top), paint);
    canvas.drawLine(
        Offset(right, top + cornerRadius), Offset(right, top + cornerLength), paint);
    canvas.drawArc(
        Rect.fromLTWH(right - cornerRadius * 2, top, cornerRadius * 2, cornerRadius * 2),
        -1.57,
        -1.57,
        false,
        paint);

    // Bottom-left corner
    canvas.drawLine(
        Offset(left, bottom - cornerLength), Offset(left, bottom - cornerRadius), paint);
    canvas.drawLine(
        Offset(left + cornerRadius, bottom), Offset(left + cornerLength, bottom), paint);
    canvas.drawArc(
        Rect.fromLTWH(left, bottom - cornerRadius * 2, cornerRadius * 2, cornerRadius * 2),
        1.57,
        -1.57,
        false,
        paint);

    // Bottom-right corner
    canvas.drawLine(
        Offset(right, bottom - cornerLength), Offset(right, bottom - cornerRadius), paint);
    canvas.drawLine(
        Offset(right - cornerLength, bottom), Offset(right - cornerRadius, bottom), paint);
    canvas.drawArc(
        Rect.fromLTWH(right - cornerRadius * 2, bottom - cornerRadius * 2, cornerRadius * 2, cornerRadius * 2),
        0,
        -1.57,
        false,
        paint);

    // Dim overlay outside frame
    final dimPaint = Paint()
      ..color = Colors.black.withOpacity(0.4);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, top), dimPaint);
    canvas.drawRect(Rect.fromLTWH(0, bottom, size.width, size.height - bottom), dimPaint);
    canvas.drawRect(Rect.fromLTWH(0, top, left, frameSize), dimPaint);
    canvas.drawRect(Rect.fromLTWH(right, top, size.width - right, frameSize), dimPaint);
  }

  @override
  bool shouldRepaint(_FramePainter old) => old.opacity != opacity;
}
