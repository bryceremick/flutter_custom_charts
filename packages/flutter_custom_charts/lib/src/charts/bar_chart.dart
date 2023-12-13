part of flutter_custom_charts;

const double _degredationFactor = 0.85;
const int _tweenTickTime = 2;

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
            _tweenTimer?.cancel();
            _tweenTimer = null;
          },
          onHorizontalDragEnd: (details) {
            _tweenTimer?.cancel();
            double velocity = details.velocity.pixelsPerSecond.dx / 50;
            int elapsedTime = 0;
            _tweenTimer = Timer.periodic(
                const Duration(milliseconds: _tweenTickTime), (timer) {
              elapsedTime += _tweenTickTime;
              velocity *= max(_degredationFactor - elapsedTime / 10000, 0.5);

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
        controller.xAxisType,
        totalAvailableBarSpace,
        controller.bars.length,
        controller.bars[i].width,
      );

      final xMaxBar = (dx + barWidth).roundToDouble();
      if (xMaxBar > chartConstraints.xMax &&
          controller.xAxisType != AxisDistanceType.pixel) {
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
        canvasRelativeYMin: _translateToCanvasPixelY(
          controller.bars[i].yMax,
          index: i,
          yAxisType: controller.yAxisType,
          chartUpperBound: controller.chartUpperBound,
          chartLowerBound: controller.chartLowerBound,
          barConstraints: chartConstraints,
        ),
        canvasRelativeYMax: _translateToCanvasPixelY(
          controller.bars[i].yMin,
          index: i,
          yAxisType: controller.yAxisType,
          chartUpperBound: controller.chartUpperBound,
          chartLowerBound: controller.chartLowerBound,
          barConstraints: chartConstraints,
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
  required ConstrainedArea barConstraints,
}) {
  late final double canvasPixelY;
  switch (yAxisType) {
    case AxisDistanceType.auto:
      canvasPixelY = (chartUpperBound - perceivedY) *
          (barConstraints.yMax - barConstraints.yMin) /
          (chartUpperBound - chartLowerBound);
    case AxisDistanceType.percentage:
      canvasPixelY =
          (barConstraints.height * (1 - perceivedY)) + barConstraints.yMin;
    case AxisDistanceType.pixel:
      canvasPixelY = barConstraints.yMax - perceivedY;
  }
  if (barConstraints.isOutOfBoundsY(canvasPixelY)) {
    throw OutOfBoundsException(
        'Bar[$index]: translated y value [$canvasPixelY] must be between [${barConstraints.yMin}] and [${barConstraints.yMax}]');
  }
  return canvasPixelY;
}

double? _nextScrollOffset(
  double dx, {
  required AxisDistanceType barWidthType,
  required double xScrollOffset,
  required double xScrollOffsetMax,
}) {
  // print('current: $xScrollOffset, max: $xScrollOffsetMax');
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
