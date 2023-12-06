import 'package:flutter/material.dart';
import 'package:three_dimensional_bar_chart/widgets/bars/bar.dart';

class Cube extends Bar {
  Cube({
    required super.fill,
    super.width,
    super.height,
    super.stroke,
    this.thirdDimensionX = 28,
    this.thirdDimensionY = 20,
    this.secondaryFill,
    this.tertiaryFill,
    this.icon,
  }) : super();

  double thirdDimensionX;
  double thirdDimensionY;
  IconData? icon;
  Color? secondaryFill;
  Color? tertiaryFill;

  @override
  Cube copyWith({
    double? width,
    double? height,
    Color? fill,
    Color? stroke,
    double? thirdDimensionX,
    double? thirdDimensionY,
    IconData? icon,
    Color? secondaryFill,
    Color? tertiaryFill,
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
      )..setBounds(
          index: index,
          xMin: xMin,
          xMax: xMax,
          yMin: yMin,
          yMax: yMax,
        );

  @override
  void draw(Canvas canvas) {
    final size = Size(xMax - xMin, yMax - yMin);
    final yMinOffset = yMin + thirdDimensionY;

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
      xMin,
      yMinOffset,
      size.width - thirdDimensionX,
      size.height - thirdDimensionY,
    );

    canvas.drawRect(front, fillPaint);
    if (stroke != null) {
      canvas.drawRect(front, strokePaint!);
    }

    // top
    final topPath = Path();
    topPath.moveTo(xMin, yMinOffset);
    topPath.lineTo(xMin + thirdDimensionX, yMinOffset - thirdDimensionY);
    topPath.lineTo(xMin + size.width, yMinOffset - thirdDimensionY);
    topPath.lineTo((xMin + size.width) - thirdDimensionX, yMinOffset);
    topPath.close();

    // right
    final rightPath = Path();
    rightPath.moveTo(xMin + size.width, yMinOffset - thirdDimensionY);
    rightPath.lineTo(xMin + size.width,
        (yMinOffset - thirdDimensionY) + (size.height - thirdDimensionY));
    rightPath.lineTo((xMin + size.width) - thirdDimensionX, yMax);
    rightPath.lineTo((xMin + size.width) - thirdDimensionX, yMinOffset);

    canvas.drawPath(topPath, secondaryFillPaint);
    canvas.drawPath(rightPath, tertiaryFillPaint);
    if (stroke != null) {
      canvas.drawPath(topPath, strokePaint!);
      canvas.drawPath(rightPath, strokePaint);
    }
  }
}
