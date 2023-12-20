part of flutter_custom_charts;

const double _degredationFactor = 0.85;
const int _tweenTickTime = 2;

// TODO - account for bars with different widths
// TODO - pass in the tween value and have the bar animate itself?

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
            final x =
                details.localPosition.dx - widget.controller.xScrollOffset;
            final y = details.localPosition.dy;

            for (int i = 0; i < widget.controller.bars.length; i++) {
              if (!widget.controller.bars[i].isOutOfBounds(x, y)) {
                widget.onTap!.call(i, widget.controller.bars[i]);
                break;
              }
            }
          },
          onHorizontalDragUpdate: (details) {
            final offset = _nextScrollOffset(
              details.delta.dx,
              barWidthType: widget.controller.xAxisType,
              xScrollOffset: widget.controller.xScrollOffset,
              xScrollOffsetMax: widget.controller.xScrollOffsetMax,
            );

            if (offset != null) {
              widget.controller.xScrollOffset = offset;
            }
          },
          onHorizontalDragStart: (details) {
            widget.controller.scrollAnimation.stop();
          },
          onHorizontalDragEnd: (details) {
            double velocity = details.velocity.pixelsPerSecond.dx / 50;
            widget.controller.scrollAnimation.onUpdate = (tweenedValue) {
              velocity *= max(_degredationFactor - tweenedValue / 10000, 0.5);
              final offset = widget.controller.xScrollOffset + velocity;
              if (offset < 0 && offset > widget.controller.xScrollOffsetMax) {
                widget.controller.xScrollOffset = offset;
              }

              if (velocity.abs() < 0.2) {
                widget.controller.scrollAnimation.stop();
              }
            };
            widget.controller.scrollAnimation.start();
          },
          child: Listener(
            onPointerSignal: (PointerSignalEvent event) {
              // final offset = _nextScrollOffset(
              //   event.delta.dx,
              //   barWidthType: widget.controller.barWidthType,
              //   xScrollOffset: widget.controller.xScrollOffset,
              //   xScrollOffsetMax: widget.controller.xScrollOffsetMax,
              // );
              // if (offset != null) {
              //   widget.controller.xScrollOffset = offset;
              // }
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

  void _paintYAxes(
    Canvas canvas,
    Size size,
    ConstrainedArea translation,
    ConstrainedArea constraints,
  ) {
    final fillPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final leftAxis = Rect.fromLTWH(
      translation.xMin,
      0,
      controller.padding.left,
      size.height,
    );

    final rightAxis = Rect.fromLTWH(
      translation.xMin + constraints.xMax,
      0,
      controller.padding.right,
      size.height,
    );

    canvas.drawRect(leftAxis, fillPaint);
    canvas.drawRect(rightAxis, fillPaint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // debugPrint('PAINTING');
    if (controller.bars.isEmpty) return;

    final constraints = ConstrainedArea(
      xMin: 0 + controller.padding.left,
      xMax: size.width - controller.padding.right,
      yMin: 0 + controller.padding.top,
      yMax: size.height - controller.padding.bottom,
    );
    controller.chartConstraints = constraints;

    final translation = controller.currentTranslation;
    canvas.translate(-translation.xMin, 0);
    // final (firstIndex, lastIndex) = controller.firstAndLastPaintedBarIndexes;

    _paintYAxes(canvas, size, translation, constraints);

    // double dx = constraints.xMin + firstIndex * controller.totalBarWidthPixels;
    int i = controller.firstPaintedBarIndex;
    T bar = controller.bars[i];
    while (bar.constraints.xMin <= translation.xMax + constraints.xMin) {
      // final xMaxBar = (dx + controller.barWidthPixels).roundToDouble();
      // if (xMaxBar > constraints.xMax &&
      //     controller.xAxisType != AxisDistanceType.pixel) {
      //   throw OutOfBoundsException(
      //       'Cannot paint bar[$i] with width [${controller.barWidthPixels}] because it exceeds the chart xMax constraint [${constraints.xMax}]');
      // }

      double dy = bar.yMax;
      if (controller.barAnimation != null &&
          controller.barAnimation!.isAnimating) {
        dy = (bar.yMax - bar.yMin) * controller.barAnimation!.value;
      }

      bar.paint(
        canvas,
        area: bar.constraints.copyWith(
          yMin: constraints.yMin,
          yMax: constraints.yMax,
        ),
        canvasRelativeYMin: _translateToCanvasPixelY(
          dy,
          index: i,
          yAxisType: controller.yAxisType,
          chartUpperBound: controller.chartUpperBound,
          chartLowerBound: controller.chartLowerBound,
          constraints: constraints,
        ),
        canvasRelativeYMax: _translateToCanvasPixelY(
          controller.bars[i].yMin,
          index: i,
          yAxisType: controller.yAxisType,
          chartUpperBound: controller.chartUpperBound,
          chartLowerBound: controller.chartLowerBound,
          constraints: constraints,
        ),
      );

      if (bar.label != null) {
        bar.label!.paint(
          canvas,
          area: bar.constraints.copyWith(
            yMin: constraints.yMax,
            yMax: constraints.yMax + controller.padding.bottom,
          ),
        );
      }

      bar = controller.bars[++i];
    }

    // print(controller.firstVisibleBarIndex);
    // print(controller._maxIterations);

    if (controller.lines.isNotEmpty) {
      for (final line in controller.lines) {
        line.paint(canvas,
            area: ConstrainedArea(
              xMin: constraints.xMin - controller.xScrollOffset,
              xMax: constraints.xMax - controller.xScrollOffset,
              yMin: constraints.yMin,
              yMax: constraints.yMax,
            ));
      }
    }

    print('----------------');
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

double _determineBarWidth(
  AxisDistanceType mode,
  double totalAvailableBarSpace,
  int barsLength,
  double? barWidth,
) {
  switch (mode) {
    case AxisDistanceType.auto:
      return totalAvailableBarSpace / barsLength;
    case AxisDistanceType.percentage:
      return totalAvailableBarSpace * barWidth!;
    case AxisDistanceType.pixel:
      return barWidth!;
  }
}

double _translateToCanvasPixelY(
  double perceivedY, {
  required int index,
  required AxisDistanceType yAxisType,
  required double chartUpperBound,
  required double chartLowerBound,
  required ConstrainedArea constraints,
}) {
  late final double canvasPixelY;
  switch (yAxisType) {
    case AxisDistanceType.auto:
      canvasPixelY = ((chartUpperBound - perceivedY) *
              (constraints.yMax - constraints.yMin) /
              (chartUpperBound - chartLowerBound)) +
          constraints.yMin;
    case AxisDistanceType.percentage:
      canvasPixelY = (constraints.height * (1 - perceivedY)) + constraints.yMin;
    case AxisDistanceType.pixel:
      canvasPixelY = constraints.yMax - perceivedY;
  }
  if (constraints.isOutOfBoundsY(canvasPixelY)) {
    throw OutOfBoundsException(
        'Bar[$index]: translated y value [$canvasPixelY] must be between [${constraints.yMin}] and [${constraints.yMax}]');
  }
  return canvasPixelY;
}

double? _nextScrollOffset(
  double dx, {
  required AxisDistanceType barWidthType,
  required double xScrollOffset,
  required double xScrollOffsetMax,
}) {
  if (barWidthType == AxisDistanceType.pixel &&
      xScrollOffset <= 0 &&
      xScrollOffset >= xScrollOffsetMax) {
    final offset = xScrollOffset + dx;
    if (offset < 0 && offset > xScrollOffsetMax) {
      return offset;
    }
  }
  return null;
}
