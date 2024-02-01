part of flutter_custom_charts;

class Point extends PlottableXYEntity with PointPainter {
  Point({
    required this.primaryAxisValue,
    required this.secondaryAxisValue,
    this.fill,
    this.stroke,
    this.strokeWidth = 1,
    this.radius = 3,
  }) : super(
          sortableValue: primaryAxisValue,
        );

  final double primaryAxisValue;
  final double secondaryAxisValue;
  final Color? fill;
  final Color? stroke;
  final double strokeWidth;
  final double radius;

  @override
  void paint(
    Canvas canvas, {
    required Offset canvasRelativePoint,
    Offset? canvasRelativePreviousPoint,
  }) {
    final paint = Paint()
      ..color = fill ?? Colors.red
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(canvasRelativePoint, radius, paint);

    if (canvasRelativePreviousPoint != null) {
      canvas.drawLine(canvasRelativePreviousPoint, canvasRelativePoint, paint);
    }
  }

  @override
  bool operator ==(covariant Point other) {
    if (identical(this, other)) return true;

    return other.primaryAxisValue == primaryAxisValue &&
        other.secondaryAxisValue == secondaryAxisValue;
  }

  @override
  int get hashCode {
    return primaryAxisValue.hashCode ^
        secondaryAxisValue.hashCode ^
        fill.hashCode ^
        stroke.hashCode ^
        strokeWidth.hashCode ^
        radius.hashCode;
  }
}
