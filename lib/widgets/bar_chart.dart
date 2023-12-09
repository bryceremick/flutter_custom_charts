import 'dart:async';

import 'package:flutter/gestures.dart';
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
  Timer? _tweenTimer;
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
            final x =
                details.localPosition.dx - widget.controller.xScrollOffset;
            final y = details.localPosition.dy;

            for (int i = 0; i < widget.controller.bars.length; i++) {
              if (!widget.controller.bars[i].constraints.isOutOfBoundsX(x) &&
                  y >= widget.controller.bars[i].calculatedYMin &&
                  y <= widget.controller.bars[i].constraints.yMax) {
                widget.onTap!.call(i, widget.controller.bars[i]);
                break;
              }
            }
          },
          onHorizontalDragUpdate: (details) {
            final offset = _nextScrollOffset(
              details.delta.dx,
              barWidthType: widget.controller.barWidthType,
              xScrollOffset: widget.controller.xScrollOffset,
              xScrollOffsetMax: widget.controller.xScrollOffsetMax,
            );

            if (offset != null) {
              widget.controller.xScrollOffset = offset;
            }
          },
          onHorizontalDragStart: (details) {
            _tweenTimer?.cancel();
            _tweenTimer = null;
          },
          onHorizontalDragEnd: (details) {
            double velocity = details.velocity.pixelsPerSecond.dx / 50;
            _tweenTimer?.cancel();
            _tweenTimer =
                Timer.periodic(const Duration(milliseconds: 2), (timer) {
              velocity *= 0.85;

              final offset = widget.controller.xScrollOffset + velocity;
              if (offset < 0 && offset > widget.controller.xScrollOffsetMax) {
                widget.controller.xScrollOffset = offset;
              }

              if (velocity.abs() < 0.01) {
                timer.cancel();
              }
            });
          },
          child: Listener(
            onPointerSignal: (PointerSignalEvent event) {
              final offset = _nextScrollOffset(
                event.delta.dx,
                barWidthType: widget.controller.barWidthType,
                xScrollOffset: widget.controller.xScrollOffset,
                xScrollOffsetMax: widget.controller.xScrollOffsetMax,
              );
              if (offset != null) {
                widget.controller.xScrollOffset = offset;
              }
            },
            child: CustomPaint(
              // size: Size(widget.width, widget.height),
              painter: _BarChartPainter(
                controller: widget.controller,
              ),
            ),
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
    // debugPrint('PAINTING');
    if (controller.bars.isEmpty) return;

    final chartConstraints = ConstrainedArea(
      xMin: 0 + controller.padding.left,
      xMax: size.width - controller.padding.right,
      yMin: 0 + controller.padding.top,
      yMax: size.height - controller.padding.bottom,
    );

    controller.chartConstraints = chartConstraints;

    final totalAvailableBarSpace = (chartConstraints.width -
        ((controller.bars.length - 1) * controller.gap));

    canvas.translate(controller.xScrollOffset, 0);

    double dx = chartConstraints.xMin;
    for (int i = 0; i < controller.bars.length; i++) {
      final barWidth = _determineBarWidth(
        controller.barWidthType,
        totalAvailableBarSpace,
        controller.bars.length,
        controller.bars[i].width,
      );

      final xMaxBar = (dx + barWidth).roundToDouble();
      if (xMaxBar > chartConstraints.xMax &&
          controller.barWidthType != BarConstraintMode.pixel) {
        throw OutOfBoundsException(
            'Cannot paint bar[$i] with width [$barWidth] because it exceeds the chart xMax constraint [${chartConstraints.xMax}]');
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
        line.paint(canvas,
            area: ConstrainedArea(
              xMin: chartConstraints.xMin - controller.xScrollOffset,
              xMax: chartConstraints.xMax - controller.xScrollOffset,
              yMin: chartConstraints.yMin,
              yMax: chartConstraints.yMax,
            ));
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

double? _nextScrollOffset(
  double dx, {
  required BarConstraintMode barWidthType,
  required double xScrollOffset,
  required double xScrollOffsetMax,
}) {
  // print('current: $xScrollOffset, max: $xScrollOffsetMax');
  if (barWidthType == BarConstraintMode.pixel &&
      xScrollOffset <= 0 &&
      xScrollOffset >= xScrollOffsetMax) {
    final offset = xScrollOffset + dx;
    if (offset < 0 && offset > xScrollOffsetMax) {
      return offset;
    }
  }
  return null;
}
