import 'package:flutter/material.dart';
import 'package:three_dimensional_bar_chart/models/bar_chart_data.dart';
import 'package:three_dimensional_bar_chart/widgets/entities/bar.dart';
import 'package:three_dimensional_bar_chart/widgets/entities/painter.dart';

class BarChart<T extends Bar> extends StatefulWidget {
  const BarChart({
    super.key,
    required this.controller,
    this.onTap,
  });

  final BarChartController<T> controller;
  final void Function(int, T)? onTap;

  @override
  State<BarChart<T>> createState() => _BarChartState<T>();
}

class _BarChartState<T extends Bar> extends State<BarChart<T>> {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        // color: Colors.red,
        border: Border.all(color: Colors.white),
      ),
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: GestureDetector(
          onTapDown: (details) {
            if (widget.onTap == null) return;

            for (int i = 0; i < widget.controller.bars.length; i++) {
              final x = details.localPosition.dx;
              final y = details.localPosition.dy;

              if (x >= widget.controller.bars[i].constraints.xMin &&
                  x <= widget.controller.bars[i].constraints.xMax &&
                  y >= widget.controller.bars[i].constraints.yMin &&
                  y <= widget.controller.bars[i].constraints.yMax) {
                widget.onTap!.call(i, widget.controller.bars[i]);
                break;
              }
            }
          },
          child: CustomPaint(
            // size: Size(widget.width, widget.height),
            painter: _BarChartPainter(controller: widget.controller),
          ),
        ),
      ),
    );
  }
}

class _BarChartPainter<T extends Bar> extends CustomPainter {
  _BarChartPainter({
    required this.controller,
  }) : super(repaint: controller);

  final BarChartController<T> controller;

  @override
  void paint(Canvas canvas, Size size) {
    debugPrint('PAINTING');
    if (controller.bars.isEmpty) return;

    _verifyPercentageConstraints(
      controller.barWidthType,
      controller.barHeightType,
      controller.bars,
    );

    double dx = 0;
    final totalAvailableBarSpace =
        (size.width - ((controller.bars.length - 1) * controller.gap));

    for (int i = 0; i < controller.bars.length; i++) {
      final barWidth = _determineBarWidth(
        controller.barWidthType,
        totalAvailableBarSpace,
        controller.bars.length,
        controller.bars[i].width,
      );

      final yMin = _determineYMin(
        controller.barHeightType,
        size.height,
        controller.bars[i].height,
        controller.offsetY.upper,
      );

      final xMax = (dx + barWidth).roundToDouble();

      if (xMax > size.width) {
        if (controller.barWidthType != BarConstraintMode.pixel) {
          // if out of bounds
          throw Exception(
              'PAINT ERROR: Bar[$i] width is too large for the available space.');
        }
        break;
      }

      // controller.bars[i].setBounds(
      //   index: i,
      //   xMin: dx,
      //   xMax: xMax,
      //   yMin: yMin,
      //   yMax: size.height,
      // );
      controller.bars[i].paint(
        canvas,
        area: ConstrainedArea(
          xMin: dx,
          xMax: xMax,
          yMin: yMin,
          yMax: size.height,
        ),
      );

      // next cube starting x position
      dx += barWidth + controller.gap;
    }

    if (controller.lines.isNotEmpty) {
      for (final line in controller.lines) {
        line.draw(
          canvas,
          xMin: 0,
          xMax: size.width,
          yMin: 0,
          yMax: size.height,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

double _determineBarWidth(
  BarConstraintMode mode,
  double totalAvailableBarSpace,
  int barsLength,
  double? barWidth,
) {
  switch (mode) {
    case BarConstraintMode.auto:
      return totalAvailableBarSpace / barsLength;
    case BarConstraintMode.percentage:
      return totalAvailableBarSpace * barWidth!;
    case BarConstraintMode.pixel:
      return barWidth!;
  }
}

double _determineYMin(
  BarConstraintMode mode,
  double sizeY,
  double? barHeight,
  double upperOffset,
) {
  switch (mode) {
    case BarConstraintMode.auto:
      return 0;
    case BarConstraintMode.percentage:
      final yMin = sizeY * (1 - barHeight!);
      if (yMin > sizeY) {
        throw Exception(
            'CHART PAINT ERROR: The height of the bar cannot be less 0%');
      }

      if (yMin < upperOffset) {
        throw Exception(
            'CHART PAINT ERROR: The height of the bar cannot exceed 100%');
      }
      return yMin;
    case BarConstraintMode.pixel:
      final yMin = sizeY - barHeight!;
      if (yMin > sizeY) {
        throw Exception(
            'CHART PAINT ERROR: The height of the bar cannot exceed $sizeY');
      }
      return yMin;
  }
}

void _verifyPercentageConstraints(
  BarConstraintMode widthMode,
  BarConstraintMode heightMode,
  List<Bar> bars,
) {
  if (widthMode == BarConstraintMode.percentage) {
    final total =
        bars.map((e) => e.width!).reduce((value, element) => value + element);
    if (total != 1) {
      throw Exception(
          'CHART PAINT ERROR: The sum of all Bar.width values must be equal to 1');
    }
  }
}
