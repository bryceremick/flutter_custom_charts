part of flutter_custom_charts;

class Point implements PointPainter {
  Point({
    required this.point,
    this.fill,
    this.stroke,
    this.strokeWidth = 1,
    this.radius = 3,
  });

  final Offset point;
  final Color? fill;
  final Color? stroke;
  final double strokeWidth;
  final double radius;

  @override
  void paint(
    Canvas canvas, {
    required Offset canvasRelativePoint,
    required Offset? canvasRelativePreviousPoint,
  }) {
    final paint = Paint()
      ..color = fill ?? Colors.red
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(point, radius, paint);

    if (canvasRelativePreviousPoint != null) {
      canvas.drawLine(canvasRelativePreviousPoint, canvasRelativePoint, paint);
    }
  }
}
