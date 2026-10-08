import 'package:flutter/material.dart';
import 'package:KKB/const/colors.dart';
import 'package:KKB/utils/text_styles.dart';

class KKBDashedButton extends StatelessWidget {
  const KKBDashedButton({super.key, required this.label, this.icon = Icons.add, this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  static const double _radius = 16;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: KKBColors.lightTextSecondary, radius: _radius),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_radius),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                Icon(icon, color: KKBColors.lightTextPrimary),
                Flexible(
                  child: Text(
                    label,
                    style: KKBTextStyles.bodyLargeBold.copyWith(color: KKBColors.lightTextPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;
  final double strokeWidth = 1;
  final double dashLength = 4;
  final double gapLength = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, size.width - strokeWidth, size.height - strokeWidth);
    final path = Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dashLength), paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
