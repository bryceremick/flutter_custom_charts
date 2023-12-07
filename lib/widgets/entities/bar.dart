import 'package:flutter/material.dart';
import 'package:three_dimensional_bar_chart/widgets/entities/line.dart';
import 'package:three_dimensional_bar_chart/widgets/entities/painter.dart';

class Bar extends ConstrainedPainter {
  Bar({
    required this.fill,
    this.stroke,
    this.width,
    this.height,
    this.lines = const [],
    super.constraints,
  });

  Color fill;
  Color? stroke;
  double? width;
  double? height;
  List<Line> lines;

  @override
  String toString() {
    return 'Bar{fill: $fill, stroke: $stroke, width: $width, height: $height, constraints: $constraints}';
  }

  Bar copyWith({
    Color? fill,
    Color? stroke,
    double? width,
    double? height,
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
    if (constraints.height <= 0) return;

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

    final front = Rect.fromLTWH(
      constraints.xMin,
      constraints.yMin,
      constraints.width,
      constraints.height,
    );

    canvas.drawRect(front, fillPaint);
    if (stroke != null) {
      canvas.drawRect(front, strokePaint!);
    }

    if (lines.isNotEmpty) {
      for (final line in lines) {
        line.draw(
          canvas,
          xMin: constraints.xMin,
          xMax: constraints.xMax,
          yMin: constraints.yMin,
          yMax: constraints.yMax,
        );
      }
    }
  }
}
