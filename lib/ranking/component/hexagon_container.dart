import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mma_flutter/common/const/colors.dart';

class HexagonContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final Color color;

  // ⭐ optional
  final Color? borderColor;
  final double? borderWidth;

  const HexagonContainer({
    super.key,
    required this.child,
    required this.width,
    required this.height,
    required this.color,
    this.borderColor,
    this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HexagonPainter(
        fillColor: color,
        borderColor: borderColor,
        borderWidth: borderWidth,
      ),
      child: SizedBox(
        width: width,
        height: height,
        child: Center(child: child),
      ),
    );
  }
}

class _HexagonPainter extends CustomPainter {
  final Color fillColor;
  final Color? borderColor;
  final double? borderWidth;

  _HexagonPainter({
    required this.fillColor,
    this.borderColor,
    this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path =
        Path()
          ..moveTo(w * 0.05, 0)
          ..lineTo(w * 0.95, 0)
          ..lineTo(w, h * 0.5)
          ..lineTo(w * 0.95, h)
          ..lineTo(w * 0.05, h)
          ..lineTo(0, h * 0.5)
          ..close();

    final fillPaint =
        Paint()
          ..color = fillColor
          ..style = PaintingStyle.fill;

    canvas.drawPath(path, fillPaint);

    if (borderColor != null && borderWidth != null) {
      final borderPaint =
          Paint()
            ..color = borderColor!
            ..style = PaintingStyle.stroke
            ..strokeWidth = borderWidth!;

      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
