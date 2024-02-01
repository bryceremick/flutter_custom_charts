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

  double get width => (xMax - xMin).abs();
  double get height => (yMax - yMin).abs();
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

  @override
  bool operator ==(covariant ConstrainedArea other) {
    if (identical(this, other)) return true;

    return other.xMin == xMin &&
        other.xMax == xMax &&
        other.yMin == yMin &&
        other.yMax == yMax;
  }

  @override
  int get hashCode {
    return xMin.hashCode ^ xMax.hashCode ^ yMin.hashCode ^ yMax.hashCode;
  }

  ConstrainedArea copyWith({
    double? xMin,
    double? xMax,
    double? yMin,
    double? yMax,
  }) {
    return ConstrainedArea(
      xMin: xMin ?? this.xMin,
      xMax: xMax ?? this.xMax,
      yMin: yMin ?? this.yMin,
      yMax: yMax ?? this.yMax,
    );
  }
}
