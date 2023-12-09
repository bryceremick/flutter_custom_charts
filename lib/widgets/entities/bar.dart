import 'package:flutter/material.dart';
import 'package:three_dimensional_bar_chart/errors/bar_chart_errors.dart';
import 'package:three_dimensional_bar_chart/models/bar_chart_data.dart';
import 'package:three_dimensional_bar_chart/widgets/entities/line.dart';
import 'package:three_dimensional_bar_chart/widgets/entities/painter.dart';

class BarDimension {
  const BarDimension({
    required this.mode,
    required this.value,
  });

  final BarConstraintMode mode;
  final double value;
}

class Bar extends ConstrainedPainter {
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
  BarDimension height;
  List<Line> lines;

  @override
  String toString() {
    return 'Bar{fill: $fill, stroke: $stroke, width: $width, height: $height, constraints: $constraints}';
  }

  double get calculatedYMin {
    late final double y;
    switch (height.mode) {
      case BarConstraintMode.auto:
        y = constraints.yMin;
      case BarConstraintMode.percentage:
        y = (constraints.height * (1 - height.value)) + constraints.yMin;
      case BarConstraintMode.pixel:
        y = constraints.yMax - height.value;
    }
    if (constraints.isOutOfBoundsY(y)) {
      throw OutOfBoundsException(
          'Calculated bar height [$y] must be between [${constraints.yMin}] and [${constraints.yMax}]');
    }
    return y;
  }

  Bar copyWith({
    Color? fill,
    Color? stroke,
    double? width,
    BarDimension? height,
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
  }) {
    constraints = area;
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
