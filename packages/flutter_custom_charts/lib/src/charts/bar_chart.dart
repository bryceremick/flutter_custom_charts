part of flutter_custom_charts;

const double _degredationFactor = 0.85;
const int _tweenTickTime = 2;

// This is the number of bars that get painted outside of the visible area
// on both sides of the chart. This is to give the chart a "scrolling" effect
const int _horizontalBarScrollPadding = 2;

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

    final barWidth = _determineBarWidth(
      controller.xAxisType,
      totalAvailableBarSpace,
      controller.bars.length,
      controller.bars[0].width,
    );

    canvas.translate(controller.xScrollOffset, 0);

    final visibleXMin = -controller.xScrollOffset + chartConstraints.xMin;
    final visibleXMax = -controller.xScrollOffset + chartConstraints.xMax;

    final totalBarWidth = barWidth + controller.gap;
    int firstVisibleBarIndex = max(
        ((visibleXMin / totalBarWidth).floor()) - _horizontalBarScrollPadding,
        0);

    int lastVisibleBarIndex = min(
        ((visibleXMax / totalBarWidth).ceil()) + _horizontalBarScrollPadding,
        controller.bars.length - 1);

    double dx = chartConstraints.xMin + firstVisibleBarIndex * totalBarWidth;
    for (int i = firstVisibleBarIndex; i < lastVisibleBarIndex; i++) {
      final xMaxBar = (dx + barWidth).roundToDouble();
      if (xMaxBar > chartConstraints.xMax &&
          controller.xAxisType != AxisDistanceType.pixel) {
        throw OutOfBoundsException(
            'Cannot paint bar[$i] with width [$barWidth] because it exceeds the chart xMax constraint [${chartConstraints.xMax}]');
      }

      double dy = controller.bars[i].yMax;
      if (controller.barAnimation != null &&
          controller.barAnimation!.isAnimating) {
        dy = (controller.bars[i].yMax - controller.bars[i].yMin) *
            controller.barAnimation!.value;
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
          dy,
          index: i,
          yAxisType: controller.yAxisType,
          chartUpperBound: controller.chartUpperBound,
          chartLowerBound: controller.chartLowerBound,
          constraints: chartConstraints,
        ),
        canvasRelativeYMax: _translateToCanvasPixelY(
          controller.bars[i].yMin,
          index: i,
          yAxisType: controller.yAxisType,
          chartUpperBound: controller.chartUpperBound,
          chartLowerBound: controller.chartLowerBound,
          constraints: chartConstraints,
        ),
      );

      if (controller.bars[i].label != null) {
        controller.bars[i].label!.paint(
          canvas,
          area: ConstrainedArea(
            xMin: dx,
            xMax: xMaxBar,
            yMin: chartConstraints.yMax,
            yMax: chartConstraints.yMax + controller.padding.bottom,
          ),
        );
      }

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
