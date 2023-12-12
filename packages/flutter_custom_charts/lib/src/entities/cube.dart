part of flutter_custom_charts;

class Cube extends Bar {
  Cube({
    required super.fill,
    required super.height,
    super.width,
    super.stroke,
    this.thirdDimensionX = 28,
    this.thirdDimensionY = 20,
    this.secondaryFill,
    this.tertiaryFill,
    this.icon,
    super.lines,
    super.constraints,
  });

  double thirdDimensionX;
  double thirdDimensionY;
  IconData? icon;
  Color? secondaryFill;
  Color? tertiaryFill;

  @override
  Cube copyWith({
    double? width,
    BarDimension? height,
    Color? fill,
    Color? stroke,
    double? thirdDimensionX,
    double? thirdDimensionY,
    IconData? icon,
    Color? secondaryFill,
    Color? tertiaryFill,
    List<Line>? lines,
    ConstrainedArea? constraints,
  }) =>
      Cube(
        width: width ?? this.width,
        height: height ?? this.height,
        fill: fill ?? this.fill,
        stroke: stroke ?? this.stroke,
        thirdDimensionX: thirdDimensionX ?? this.thirdDimensionX,
        thirdDimensionY: thirdDimensionY ?? this.thirdDimensionY,
        icon: icon ?? this.icon,
        secondaryFill: secondaryFill ?? this.secondaryFill,
        tertiaryFill: tertiaryFill ?? this.tertiaryFill,
        lines: lines ?? this.lines,
        constraints: constraints ?? this.constraints,
      );

  @override
  void paint(
    Canvas canvas, {
    required ConstrainedArea area,
  }) {
    constraints = area;
    final yMinOffset = constraints.yMin + thirdDimensionY;

    if (constraints.height <= 0) return;

    final fillPaint = Paint()
      ..color = fill
      ..style = PaintingStyle.fill;

    final secondaryFillPaint = Paint()
      ..color = secondaryFill ?? fill
      ..style = PaintingStyle.fill;

    final tertiaryFillPaint = Paint()
      ..color = tertiaryFill ?? fill
      ..style = PaintingStyle.fill;

    Paint? strokePaint;

    if (stroke != null) {
      strokePaint = Paint()
        ..color = stroke!
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
    }

    // draw front
    final front = Rect.fromLTWH(
      constraints.xMin,
      yMinOffset,
      constraints.width - thirdDimensionX,
      constraints.height - thirdDimensionY,
    );

    canvas.drawRect(front, fillPaint);
    if (stroke != null) {
      canvas.drawRect(front, strokePaint!);
    }

    // top
    final topPath = Path();
    topPath.moveTo(constraints.xMin, yMinOffset);
    topPath.lineTo(
        constraints.xMin + thirdDimensionX, yMinOffset - thirdDimensionY);
    topPath.lineTo(
        constraints.xMin + constraints.width, yMinOffset - thirdDimensionY);
    topPath.lineTo(
        (constraints.xMin + constraints.width) - thirdDimensionX, yMinOffset);
    topPath.close();

    // right
    final rightPath = Path();
    rightPath.moveTo(
        constraints.xMin + constraints.width, yMinOffset - thirdDimensionY);
    rightPath.lineTo(
        constraints.xMin + constraints.width,
        (yMinOffset - thirdDimensionY) +
            (constraints.height - thirdDimensionY));
    rightPath.lineTo((constraints.xMin + constraints.width) - thirdDimensionX,
        constraints.yMax);
    rightPath.lineTo(
        (constraints.xMin + constraints.width) - thirdDimensionX, yMinOffset);

    canvas.drawPath(topPath, secondaryFillPaint);
    canvas.drawPath(rightPath, tertiaryFillPaint);
    if (stroke != null) {
      canvas.drawPath(topPath, strokePaint!);
      canvas.drawPath(rightPath, strokePaint);
    }
  }
}
