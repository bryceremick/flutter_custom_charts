part of flutter_custom_charts;

class Bar extends BarPainter {
  Bar({
    required this.fill,
    required this.height,
    this.stroke,
    this.width,
    this.label,
    this.lines = const [],
    super.constraints,
  });

  Color fill;
  Color? stroke;
  double? width;
  String? label;
  double height;
  List<Line> lines;

  AxisDistanceType _yAxisType = AxisDistanceType.auto;
  double? _maxHeight = 0;

  @override
  String toString() {
    return 'Bar{fill: $fill, stroke: $stroke, width: $width, height: $height, constraints: $constraints}';
  }

  double get calculatedYMin {
    late final double y;
    switch (_yAxisType) {
      case AxisDistanceType.auto:
        y = (constraints.height * (1 - (height / _maxHeight!))) +
            constraints.yMin;
      case AxisDistanceType.percentage:
        y = (constraints.height * (1 - height)) + constraints.yMin;
      case AxisDistanceType.pixel:
        y = constraints.yMax - height;
    }
    if (constraints.isOutOfBoundsY(y)) {
      throw OutOfBoundsException(
          'Calculated bar height [$y] must be between [${constraints.yMin}] and [${constraints.yMax}]');
    }
    return y;
  }

  bool isOutOfBounds(double x, double y) {
    return constraints.isOutOfBoundsX(x) ||
        y < calculatedYMin ||
        y > constraints.yMax;
  }

  Bar copyWith({
    Color? fill,
    Color? stroke,
    double? width,
    double? height,
    List<Line>? lines,
    ConstrainedArea? constraints,
  }) =>
      Bar(
        fill: fill ?? this.fill,
        stroke: stroke ?? this.stroke,
        width: width ?? this.width,
        height: height ?? this.height,
        lines: lines ?? this.lines,
        constraints: constraints ?? this.constraints,
      );

  @override
  void paint(
    Canvas canvas, {
    required ConstrainedArea area,
    required AxisDistanceType yAxisType,
    double? maxHeight,
  }) {
    super.constraints = area;
    _yAxisType = yAxisType;
    _maxHeight = maxHeight;

    if (constraints.height <= 0 || constraints.width <= 0) {
      return;
    }

    final fillPaint = Paint()
      ..color = fill
      ..style = PaintingStyle.fill;

    Paint? strokePaint;
    if (stroke != null) {
      strokePaint = Paint()
        ..color = stroke!
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
    }

    final yMin = calculatedYMin;

    final bar = Rect.fromLTRB(
      constraints.xMin,
      yMin,
      constraints.xMax,
      constraints.yMax,
    );

    canvas.drawRect(bar, fillPaint);
    if (stroke != null) {
      canvas.drawRect(bar, strokePaint!);
    }

    if (lines.isNotEmpty) {
      for (final line in lines) {
        line.paint(
          canvas,
          area: ConstrainedArea(
            xMin: constraints.xMin,
            xMax: constraints.xMax,
            yMin: yMin,
            yMax: constraints.yMax,
          ),
        );
      }
    }
  }
}
