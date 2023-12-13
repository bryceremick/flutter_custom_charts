part of flutter_custom_charts;

class Bar extends BarPainter {
  Bar({
    required this.fill,
    required this.yMax,
    this.yMin = 0,
    this.stroke,
    this.width,
    this.label,
    this.lines = const [],
    super.constraints,
  });

  final Color fill;
  final Color? stroke;
  double? width;
  String? label;
  EdgeInsets padding = const EdgeInsets.all(0);
  double yMax;
  double yMin;
  List<Line> lines;

  AxisDistanceType _yAxisType = AxisDistanceType.auto;
  double? _maxHeight = 0;

  @override
  String toString() {
    return 'Bar{fill: $fill, stroke: $stroke, width: $width, yMax: $yMax, constraints: $constraints}';
  }

  double get _canvasRelativeYMin {
    return _translateToCanvasY(yMax);
  }

  double get _canvasRelativeYMax {
    return _translateToCanvasY(yMin);
  }

  double _translateToCanvasY(double perceivedY) {
    late final double canvasY;
    switch (_yAxisType) {
      case AxisDistanceType.auto:
        canvasY = (constraints.height * (1 - (perceivedY / _maxHeight!))) +
            constraints.yMin;
      case AxisDistanceType.percentage:
        canvasY = (constraints.height * (1 - perceivedY)) + constraints.yMin;
      case AxisDistanceType.pixel:
        canvasY = constraints.yMax - perceivedY;
    }
    if (constraints.isOutOfBoundsY(canvasY)) {
      throw OutOfBoundsException(
          'Calculated bar height [$canvasY] must be between [${constraints.yMin}] and [${constraints.yMax}]');
    }
    return canvasY;
  }

  double get height => yMax - yMin;

  bool isOutOfBounds(double x, double y) {
    return constraints.isOutOfBoundsX(x) ||
        y < _canvasRelativeYMin ||
        y > _canvasRelativeYMax;
  }

  Bar copyWith({
    Color? fill,
    Color? stroke,
    double? width,
    double? yMax,
    double? yMin,
    List<Line>? lines,
    ConstrainedArea? constraints,
  }) =>
      Bar(
        fill: fill ?? this.fill,
        stroke: stroke ?? this.stroke,
        width: width ?? this.width,
        yMax: yMax ?? this.yMax,
        yMin: yMin ?? this.yMin,
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

    if (height <= 0 || constraints.height <= 0 || constraints.width <= 0) {
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

    final yMinCanvas = _canvasRelativeYMin;
    final yMaxCanvas = _canvasRelativeYMax;

    final bar = Rect.fromLTRB(
      constraints.xMin,
      yMinCanvas,
      constraints.xMax,
      yMaxCanvas,
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
            yMin: yMinCanvas,
            yMax: yMaxCanvas,
          ),
        );
      }
    }
  }
}
