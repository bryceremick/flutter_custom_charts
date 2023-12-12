part of flutter_custom_charts;

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
}

abstract class BarPainter implements ConstrainedPainter {
  BarPainter({
    this.constraints = const ConstrainedArea(
      xMin: 0,
      xMax: 0,
      yMin: 0,
      yMax: 0,
    ),
  });

  @override
  ConstrainedArea constraints;

  void paint(
    Canvas canvas, {
    required ConstrainedArea area,
    required AxisDistanceType yAxisType,
    double? maxHeight,
  }) {
    constraints = area;
  }
}

abstract class LinePainter implements ConstrainedPainter {
  LinePainter({
    this.constraints = const ConstrainedArea(
      xMin: 0,
      xMax: 0,
      yMin: 0,
      yMax: 0,
    ),
  });

  @override
  ConstrainedArea constraints;

  void paint(
    Canvas canvas, {
    required ConstrainedArea area,
  }) {
    constraints = area;
  }
}
