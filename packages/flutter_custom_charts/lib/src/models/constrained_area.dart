part of flutter_custom_charts;

const _tolerance = 0.0001;

class ConstrainedArea {
  const ConstrainedArea({
    required this.xMin,
    required this.xMax,
    required this.yMin,
    required this.yMax,
  });

  const ConstrainedArea.empty()
      : xMin = 0,
        xMax = 0,
        yMin = 0,
        yMax = 0;

  final double xMin;
  final double xMax;
  final double yMin;
  final double yMax;

  double get width => xMax - xMin;
  double get height => yMax - yMin;
  Size get size => Size(width, height);

  bool isOutOfBoundsY(double y) =>
      y < yMin - _tolerance || y > yMax + _tolerance;
  bool isOutOfBoundsX(double x) =>
      x < xMin - _tolerance || x > xMax + _tolerance;

  bool isOutOfBounds(double x, double y) =>
      isOutOfBoundsX(x) || isOutOfBoundsY(y);

  ConstrainedArea shrink(EdgeInsets padding) => ConstrainedArea(
        xMin: xMin + padding.left,
        xMax: xMax - padding.right,
        yMin: yMin + padding.top,
        yMax: yMax - padding.bottom,
      );

  @override
  String toString() {
    return 'ConstrainedArea(xMin: $xMin, xMax: $xMax, yMin: $yMin, yMax: $yMax)';
  }
}
