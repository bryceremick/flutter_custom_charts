import 'package:flutter/material.dart';

class Bar {
  Bar({
    required this.fill,
    this.stroke,
    this.width,
    this.height,
  });

  Color fill;
  Color? stroke;
  double? width;
  double? height;
  int _index = 0;

  double _xMin = 0.0;
  double _xMax = 0.0;
  double _yMin = 0.0;
  double _yMax = 0.0;

  int get index => _index;
  double get xMin => _xMin;
  double get xMax => _xMax;
  double get yMin => _yMin;
  double get yMax => _yMax;

  @override
  String toString() {
    return 'Bar{fill: $fill, stroke: $stroke, width: $width, height: $height, index:$index, xMin: $xMin, xMax: $xMax, yMin: $yMin, yMax: $yMax}';
  }

  /// For internal painting only. Using this method could have unexpected results.
  void setBounds({
    required int index,
    required double xMin,
    required double xMax,
    required double yMin,
    required double yMax,
  }) {
    _index = index;
    _xMin = xMin;
    _xMax = xMax;
    _yMin = yMin;
    _yMax = yMax;
  }

  Bar copyWith({
    Color? fill,
    Color? stroke,
    double? width,
    double? height,
  }) =>
      Bar(
        fill: fill ?? this.fill,
        stroke: stroke ?? this.stroke,
        width: width ?? this.width,
        height: height ?? this.height,
      )..setBounds(
          index: _index,
          xMin: _xMin,
          xMax: _xMax,
          yMin: _yMin,
          yMax: _yMax,
        );

  void draw(Canvas canvas) {
    final size = Size(xMax - xMin, yMax - yMin);

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
      _xMin,
      _yMin,
      size.width,
      size.height,
    );

    canvas.drawRect(front, fillPaint);
    if (stroke != null) {
      canvas.drawRect(front, strokePaint!);
    }
  }
}
