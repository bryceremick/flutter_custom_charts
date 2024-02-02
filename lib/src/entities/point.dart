part of flutter_custom_charts;

class Point extends PlottableXYEntity with PointPainter {
  Point({
    required this.primaryAxisValue,
    required this.secondaryAxisValue,
    this.fill = Colors.white,
    this.stroke = Colors.white,
    this.strokeWidth = 1,
    this.radius = 3,
  }) : super(
          sortableValue: primaryAxisValue,
        ) {
    assert(fill != null || stroke != null,
        'A point must have either a fill or a stroke');
  }

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
    Offset? canvasRelativeNextPoint,
    Color? nextPointFill,
  }) {
    // connectPoints = true
    if (canvasRelativeNextPoint != null) {
      late final Paint linePaint;

      if (stroke == null && nextPointFill == null) {
        return;
      } else if (stroke == null && nextPointFill != null) {
        // if no stroke specified, try to paint a gradient between the two fills
        linePaint = Paint()
          ..shader = LinearGradient(
            colors: [fill!, nextPointFill],
          ).createShader(
            Rect.fromPoints(
              canvasRelativePoint,
              canvasRelativeNextPoint,
            ),
          )
          ..strokeWidth = strokeWidth;
      } else {
        linePaint = Paint()
          ..color = stroke!
          ..strokeWidth = strokeWidth;
      }

      canvas.drawLine(canvasRelativePoint, canvasRelativeNextPoint, linePaint);
    }

    if (radius > 0 && fill != null) {
      final pointPaint = Paint()
        ..color = fill!
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawCircle(canvasRelativePoint, radius, pointPaint);
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
