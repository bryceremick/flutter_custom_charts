part of flutter_custom_charts;

abstract mixin class ConstrainedPainter {
  ConstrainedArea constraints = const ConstrainedArea.empty();

  void paint(
    Canvas canvas, {
    required ConstrainedArea constraints,
  }) {
    this.constraints = constraints;
  }
}

abstract class AxisPainter {
  void paint(
    Canvas canvas, {
    required ConstrainedArea constraints,
    required Offset? canvasRelativePreviousPoint,
  });
}

abstract class BarPainter {
  ConstrainedArea constraints = const ConstrainedArea.empty();
  ConstrainedArea barArea = const ConstrainedArea.empty();

  void paint(
    Canvas canvas, {
    required ConstrainedArea constraints,
    required ConstrainedArea barArea,
  }) {
    this.constraints = constraints;
    this.barArea = barArea;
  }
}

abstract class PointPainter {
  void paint(
    Canvas canvas, {
    required Offset canvasRelativePoint,
    required Offset? canvasRelativePreviousPoint,
  });
}


/*
abstract class LinePainter implements ConstrainedPainter {
  LinePainter({
    this.constraints = const ConstrainedArea.empty(),
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

abstract class LabelPainter implements ConstrainedPainter {
  LabelPainter({
    this.constraints = const ConstrainedArea.empty(),
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

abstract class ChartPainter implements ConstrainedPainter {
  ChartPainter({
    this.constraints = const ConstrainedArea.empty(),
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
*/