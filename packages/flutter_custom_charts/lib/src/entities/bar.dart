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
  final double yMax;
  final double yMin;
  late double _canvasRelativeYMin;
  late double _canvasRelativeYMax;
  List<Line> lines;

  @override
  String toString() {
    return 'Bar{fill: $fill, stroke: $stroke, width: $width, yMax: $yMax, constraints: $constraints}';
  }

  double get perceivedHeight => yMax - yMin;

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
    required double canvasRelativeYMin,
    required double canvasRelativeYMax,
  }) {
    super.constraints = area;
    _canvasRelativeYMin = canvasRelativeYMin;
    _canvasRelativeYMax = canvasRelativeYMax;

    if (perceivedHeight <= 0 ||
        constraints.height <= 0 ||
        constraints.width <= 0) {
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

    final l = constraints.xMin + padding.left;
    final t = yMinCanvas + padding.top;
    final r = constraints.xMax - padding.right;
    final b = yMaxCanvas - padding.bottom;

    final bar = Rect.fromLTRB(l, t, r, b);

    canvas.drawRect(bar, fillPaint);
    if (stroke != null) {
      canvas.drawRect(bar, strokePaint!);
    }

    if (lines.isNotEmpty) {
      for (final line in lines) {
        line.paint(
          canvas,
          area: ConstrainedArea(
            xMin: l,
            xMax: r,
            yMin: t,
            yMax: b,
          ),
        );
      }
    }
  }
}
