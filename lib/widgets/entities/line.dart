import 'package:flutter/widgets.dart';
import 'package:three_dimensional_bar_chart/widgets/entities/painter.dart';

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

abstract class DefaultLineStyle {
  const DefaultLineStyle();
}

class Dashed extends DefaultLineStyle {
  const Dashed({
    this.width = 4.0,
    this.gap = 4.0,
  });
  final double width;
  final double gap;
}

abstract class Line<T extends DefaultLineStyle> extends ConstrainedPainter {
  Line({
    required this.fill,
    required this.width,
    required this.height,
    this.style,
    super.constraints,
  });

  final Color fill;
  final LineDimension width;
  final LineDimension height;
  final T? style;
}

class HorizontalLine<T extends DefaultLineStyle> extends Line {
  HorizontalLine({
    required super.fill,
    required this.dy,
    required super.width,
    required super.height,
    T? style,
    super.constraints,
  }) : super(style: style);

  final LineDimension dy;

  @override
  void paint(
    Canvas canvas, {
    required ConstrainedArea area,
  }) {
    constraints = area;
    double lineEndX = width.mode == LineConstraintMode.percentage
        ? constraints.xMin + (width.value * constraints.width)
        : constraints.xMin + width.value;

    double lineY = dy.mode == LineConstraintMode.percentage
        ? constraints.yMin + ((1 - dy.value) * constraints.height)
        : constraints.yMin + dy.value;

    if (lineEndX <= constraints.xMin ||
        lineY < constraints.yMin ||
        lineY > constraints.yMax) return;
    if (lineEndX > constraints.xMax) {
      lineEndX = constraints.xMax;
    }

    final paint = Paint()
      ..color = fill
      ..strokeWidth = height.mode == LineConstraintMode.percentage
          ? constraints.height * height.value
          : height.value
      ..style = PaintingStyle.stroke;

    if (style != null) {
      if (style is Dashed) {
        final dashWidth = (style as Dashed).width;
        final dashGap = (style as Dashed).gap;

        double dx = constraints.xMin;

        final dash = Path();

        while (dx < (lineEndX - dashWidth)) {
          dash
            ..moveTo(dx, lineY)
            ..lineTo(dx + dashWidth, lineY);
          dx += dashWidth + dashGap;
        }

        if (lineEndX - dx > 0) {
          dash
            ..moveTo(dx, lineY)
            ..lineTo(lineEndX, lineY);
        }
        canvas.drawPath(dash, paint);
        return;
      }
    }

    final p1 = Offset(constraints.xMin, lineY);
    final p2 = Offset(lineEndX, lineY);

    canvas.drawLine(p1, p2, paint);
  }
}
