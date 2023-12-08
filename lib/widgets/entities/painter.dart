import 'dart:ui';

class ConstrainedArea {
  const ConstrainedArea({
    required this.xMin,
    required this.xMax,
    required this.yMin,
    required this.yMax,
  });

  final double xMin;
  final double xMax;
  final double yMin;
  final double yMax;

  double get width => xMax - xMin;
  double get height => yMax - yMin;
  Size get size => Size(width, height);

  bool isOutOfBoundsY(double y) => y < yMin || y > yMax;
  bool isOutOfBoundsX(double x) => x < xMin || x > xMax;
  bool isOutOfBounds(double x, double y) =>
      isOutOfBoundsX(x) || isOutOfBoundsY(y);

  @override
  String toString() {
    return 'ConstrainedArea(xMin: $xMin, xMax: $xMax, yMin: $yMin, yMax: $yMax)';
  }
}

abstract class ConstrainedPainter {
  ConstrainedPainter({
    this.constraints = const ConstrainedArea(
      xMin: 0,
      xMax: 0,
      yMin: 0,
      yMax: 0,
    ),
  });

  ConstrainedArea constraints;

  void paint(
    Canvas canvas, {
    required ConstrainedArea area,
  }) {
    constraints = area;
  }
}
