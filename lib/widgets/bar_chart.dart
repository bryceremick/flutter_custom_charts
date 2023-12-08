import 'package:flutter/material.dart';
import 'package:three_dimensional_bar_chart/errors/bar_chart_errors.dart';
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

    final chartConstraints = ConstrainedArea(
      xMin: 0 + controller.padding.left,
      xMax: size.width - controller.padding.right,
      yMin: 0 + controller.padding.top,
      yMax: size.height - controller.padding.bottom,
    );

    double dx = chartConstraints.xMin;

    final totalAvailableBarSpace = (chartConstraints.width -
        ((controller.bars.length - 1) * controller.gap));

    for (int i = 0; i < controller.bars.length; i++) {
      final barWidth = _determineBarWidth(
        controller.barWidthType,
        totalAvailableBarSpace,
        controller.bars.length,
        controller.bars[i].width,
      );

      final xMaxBar = (dx + barWidth).roundToDouble();
      if (xMaxBar > chartConstraints.xMax) {
        if (controller.barWidthType != BarConstraintMode.pixel) {
          // if out of bounds
          throw OutOfBoundsException(
              'Cannot paint bar[$i] with width [$barWidth] because it exceeds the chart xMax constraint [${chartConstraints.xMax}]');
        }
        break;
      }

      controller.bars[i].paint(
        canvas,
        area: ConstrainedArea(
          xMin: dx,
          xMax: xMaxBar,
          yMin: chartConstraints.yMin,
          yMax: chartConstraints.yMax,
        ),
      );

      // next bar xMin
      dx += barWidth + controller.gap;
    }

    if (controller.lines.isNotEmpty) {
      for (final line in controller.lines) {
        line.paint(canvas, area: chartConstraints);
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
