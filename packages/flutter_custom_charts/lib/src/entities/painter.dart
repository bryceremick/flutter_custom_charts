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

  void paint(
    Canvas canvas, {
    required ConstrainedArea area,
  }) {
    constraints = area;
  }
}
