import 'package:flutter/widgets.dart';

/// [pixel] - The constraint of the line is the pixel value of [Line.width] or [Line.height].
///
/// [percentage] - The constraint of the line is the percentage value of [Line.width] or [Line.height].
enum LineConstraintMode {
  pixel,
  percentage,
}

class LineDimension {
  const LineDimension({
    required this.mode,
    required this.value,
  });

  final LineConstraintMode mode;
  final double value;
}

abstract class Line {
  const Line({
    required this.fill,
    required this.width,
    required this.height,
  });

  final Color fill;
  final LineDimension width;
  final LineDimension height;

  void draw(
    Canvas canvas, {
    required double xMin,
    required double xMax,
    required double yMin,
    required double yMax,
  });
}

class HorizontalLine extends Line {
  const HorizontalLine({
    required super.fill,
    required this.dy,
    required super.width,
    required super.height,
  });

  final LineDimension dy;

  @override
  void draw(
    Canvas canvas, {
    required double xMin,
    required double xMax,
    required double yMin,
    required double yMax,
  }) {
    final constraints = Size(xMax - xMin, yMax - yMin);
    double lineEndX = width.mode == LineConstraintMode.percentage
        ? xMin + (width.value * constraints.width)
        : xMin + width.value;

    double lineY = dy.mode == LineConstraintMode.percentage
        ? yMin + ((1 - dy.value) * constraints.height)
        : yMin + dy.value;

    if (lineEndX <= xMin || lineY < yMin || lineY > yMax) return;
    if (lineEndX > xMax) {
      lineEndX = xMax;
    }

    final p1 = Offset(xMin, lineY);
    final p2 = Offset(lineEndX, lineY);

    final paint = Paint()
      ..color = fill
      ..strokeWidth = height.mode == LineConstraintMode.percentage
          ? constraints.height * height.value
          : height.value
      ..style = PaintingStyle.stroke;

    canvas.drawLine(p1, p2, paint);
  }
}
