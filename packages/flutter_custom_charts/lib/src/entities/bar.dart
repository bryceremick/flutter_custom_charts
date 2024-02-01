part of flutter_custom_charts;

// TODO - change secondaryAxisMax and secondaryAxisMin to a Range instance

class Bar extends PlottableXYEntity with ConstrainedPainter {
  Bar({
    required this.primaryAxisMin,
    required this.primaryAxisMax,
    required this.secondaryAxisMax,
    this.secondaryAxisMin = 0,
    this.fill = Colors.blue,
    this.stroke,
    this.label,
    this.lines = const [],
  }) : super(sortableValue: primaryAxisMin) {
    if (secondaryAxisMin >= secondaryAxisMax) {
      throw XYChartException('Bar yMin must be less than yMax');
    }
    if (primaryAxisMin >= primaryAxisMax) {
      throw XYChartException('Bar xMin must be less than xMax');
    }
  }

  final Color? fill;
  final Color? stroke;
  final Label? label;
  final EdgeInsets padding = const EdgeInsets.all(0);
  final double secondaryAxisMax;
  final double secondaryAxisMin;

  final double primaryAxisMin;
  final double primaryAxisMax;
  final List<Line> lines;

  double get perceivedHeight => (secondaryAxisMax - secondaryAxisMin).abs();
  double get perceivedWidth => (primaryAxisMax - primaryAxisMin).abs();

  // bool isOutOfBounds(double x, double y) {
  //   return constraints.isOutOfBoundsX(x) ||
  //       y < barArea.yMin ||
  //       y > barArea.yMax;
  // }

  Range get secondaryAxisRange => Range(
        min: secondaryAxisMin,
        max: secondaryAxisMax,
      );

  @override
  void paint(
    Canvas canvas, {
    required ConstrainedArea constraints,
    // required ConstrainedArea barArea,
  }) {
    super.constraints = constraints;
    // super.barArea = barArea;

    if (perceivedHeight == 0 ||
        constraints.height == 0 ||
        constraints.width == 0) {
      return;
    }

    Paint? strokePaint;
    Paint? fillPaint;

    if (fill == null && stroke == null) {
      throw XYChartException('Bar fill and stroke cannot both be null');
    }

    if (fill != null) {
      fillPaint = Paint()
        ..color = fill!
        ..style = PaintingStyle.fill;
    }

    if (stroke != null) {
      strokePaint = Paint()
        ..color = stroke!
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
    }

    final l = super.constraints.xMin + padding.left;
    // final t = super.barArea.yMin + padding.top;
    final t = super.constraints.yMin + padding.top;
    final r = super.constraints.xMax - padding.right;
    // final b = super.barArea.yMax - padding.bottom;
    final b = super.constraints.yMax - padding.bottom;

    final bar = Rect.fromLTRB(l, t, r, b);

    if (fill != null) {
      canvas.drawRect(bar, fillPaint!);
    }

    if (stroke != null) {
      canvas.drawRect(bar, strokePaint!);
    }

    if (lines.isNotEmpty) {
      for (final line in lines) {
        line.paint(
          canvas,
          constraints: ConstrainedArea(
            xMin: l,
            xMax: r,
            yMin: t,
            yMax: b,
          ),
        );
      }
    }

    if (label != null) {
      label!.paint(
        canvas,
        constraints: ConstrainedArea(
          xMin: l,
          xMax: r,
          yMin: t,
          yMax: b,
        ),
      );
    }
  }

  @override
  bool operator ==(covariant Bar other) {
    if (identical(this, other)) return true;

    return other.secondaryAxisMax == secondaryAxisMax &&
        other.secondaryAxisMin == secondaryAxisMin &&
        other.primaryAxisMax == primaryAxisMax &&
        other.primaryAxisMin == primaryAxisMin;
  }

  @override
  int get hashCode {
    return fill.hashCode ^
        stroke.hashCode ^
        label.hashCode ^
        secondaryAxisMax.hashCode ^
        secondaryAxisMin.hashCode ^
        primaryAxisMax.hashCode ^
        primaryAxisMin.hashCode ^
        lines.hashCode;
  }
}
