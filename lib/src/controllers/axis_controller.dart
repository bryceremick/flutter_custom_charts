part of flutter_custom_charts;

class _ChartAxisArea {
  _ChartAxisArea({
    required this.axisIndex,
    required this.position,
    required this.area,
  });

  final int axisIndex;
  final AxisPosition position;
  ConstrainedArea area;

  @override
  String toString() =>
      '_ChartAxisArea(axisIndex: $axisIndex, position: $position, area: $area)';
}

abstract class _AxisController extends ChangeNotifier {
  _AxisController({
    required this.position,
    Range? explicitRange,
    void Function(Range?)? onExplicitRangeChange,
  })  : _explicitRange = explicitRange,
        _onExplicitRangeChange = onExplicitRangeChange;

  final AxisPosition position;
  Range? _explicitRange;

  final void Function(Range?)? _onExplicitRangeChange;

  Range? get explicitRange => _explicitRange;
  AxisDirection get direction =>
      position == AxisPosition.left || position == AxisPosition.right
          ? AxisDirection.vertical
          : AxisDirection.horizontal;

  set explicitRange(Range? range) {
    if (range != _explicitRange) {
      _explicitRange = range;
      notifyListeners();
      _onExplicitRangeChange?.call(_explicitRange);
    }
  }

  Range _getMainAlignmentCanvasRange(ConstrainedArea constraints) =>
      direction == AxisDirection.horizontal
          ? Range(
              min: constraints.xMin,
              max: constraints.xMax,
            )
          : Range(
              min: constraints.yMin,
              max: constraints.yMax,
            );

  Range _getCrossAlignmentCanvasRange(ConstrainedArea constraints) =>
      direction == AxisDirection.horizontal
          ? Range(
              min: constraints.yMin,
              max: constraints.yMax,
            )
          : Range(
              min: constraints.xMin,
              max: constraints.xMax,
            );

  void _paintAxisDetails(
    Canvas canvas, {
    required ConstrainedArea constraints,
    required AxisDetails details,
    required Range datasetRange,
    required bool isInverted,
  }) {
    final steps = datasetRange.generateSteps(details.steps);
    final mainAlignmentRange = _getMainAlignmentCanvasRange(constraints);
    final crossAlignmentRange = _getCrossAlignmentCanvasRange(constraints);

    // background
    paintRectangle(
      canvas,
      constraints: constraints,
      fill: Colors.transparent,
    );

    for (final step in steps) {
      final stepLabel = details.stepLabelFormatter(step);
      final stepLabelPainter = TextPainter(
        text: TextSpan(
          text: stepLabel,
          style: details.stepLabelStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      double mainAlignmentRangeCanvasValue = linearTransform(
        step,
        rangeA: isInverted ? datasetRange.inverted() : datasetRange,
        // rangeA: datasetRange,
        rangeB: mainAlignmentRange,
      );

      final labelAdjustmentFactor = (direction == AxisDirection.horizontal
          ? stepLabelPainter.width
          : stepLabelPainter.height);

      // prevent painting step label out of bounds
      if (mainAlignmentRangeCanvasValue >= mainAlignmentRange.max) {
        mainAlignmentRangeCanvasValue =
            mainAlignmentRange.max - labelAdjustmentFactor;
      } else if (mainAlignmentRangeCanvasValue <= mainAlignmentRange.min) {
        mainAlignmentRangeCanvasValue = mainAlignmentRange.min;
      } else {
        mainAlignmentRangeCanvasValue -= labelAdjustmentFactor / 2;
      }

      // center in cross alignment range (for centering label)
      final crossAlignmentRangeCanvasValue =
          crossAlignmentRange.midpoint() - (stepLabelPainter.height / 2);

      final stepLabelOffset = direction == AxisDirection.horizontal
          ? Offset(
              mainAlignmentRangeCanvasValue, crossAlignmentRangeCanvasValue)
          : Offset(
              crossAlignmentRangeCanvasValue, mainAlignmentRangeCanvasValue);

      stepLabelPainter.paint(canvas, stepLabelOffset);
    }
  }

  void _paintAxisGrid(
    Canvas canvas, {
    required ConstrainedArea constraints,
    required AxisDetails details,
    required Range datasetRange,
  }) {
    if (details.gridStyle == null) {
      return;
    }

    final steps = datasetRange.generateSteps(details.steps);
    final mainAlignmentCanvasRange = _getMainAlignmentCanvasRange(constraints);

    for (final step in steps) {
      final mainAlignmentRangeCanvasValue = linearTransform(
        step,
        rangeA: datasetRange,
        rangeB: mainAlignmentCanvasRange,
      );

      final p1 = direction == AxisDirection.horizontal
          ? Offset(mainAlignmentRangeCanvasValue, constraints.yMin)
          : Offset(constraints.xMin, mainAlignmentRangeCanvasValue);

      final p2 = direction == AxisDirection.horizontal
          ? Offset(mainAlignmentRangeCanvasValue, constraints.yMax)
          : Offset(constraints.xMax, mainAlignmentRangeCanvasValue);

      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = details.gridStyle!.color
          ..strokeWidth = details.gridStyle!.strokeWidth,
      );
    }
  }
}

abstract class PrimaryAxisController extends _AxisController
    with ConstrainedPainter
    implements TickerProvider {
  PrimaryAxisController({
    required super.position,
    required this.isScrollable,
    this.scrollableRange,
    this.barDetailsSpacing,
    super.explicitRange,
    super.onExplicitRangeChange,
  });

  final bool isScrollable;
  final BarDetailsSpacing? barDetailsSpacing;
  final Range? scrollableRange;
  ChartAnimation? _zoomAnimation;
  final List<_ChartAxisArea> _axisAreas = [];

  Range? get _implicitPrimaryAxisDataRange => null;

  _onDragUpdate(
    DragUpdateDetails details, {
    required Range implicitDatasetRange,
  }) {
    if (details.delta == Offset.zero || !isScrollable) {
      return;
    }

    late final double delta;
    if (direction == AxisDirection.horizontal) {
      // TODO - should probably use delta.direction instead of dy
      if (details.delta.dy != 0) {
        return;
      }

      delta = calculateDragDelta(
        details.delta.dx,
        canvasRange: Range(min: constraints.xMin, max: constraints.xMax),
        implicitDatasetRange: implicitDatasetRange,
        explicitDatasetRange: explicitRange ?? implicitDatasetRange,
      );
    } else if (direction == AxisDirection.vertical) {
      if (details.delta.dx != 0) {
        return;
      }
      delta = calculateDragDelta(
        details.delta.dy,
        canvasRange: Range(min: constraints.yMin, max: constraints.yMax),
        implicitDatasetRange: implicitDatasetRange,
        explicitDatasetRange: explicitRange ?? implicitDatasetRange,
      );
    }

    final newRange = Range(
      min: (explicitRange != null
              ? explicitRange!.min
              : implicitDatasetRange.min) -
          delta,
      max: (explicitRange != null
              ? explicitRange!.max
              : implicitDatasetRange.max) -
          delta,
    );

    if (!newRange.isWithin(scrollableRange ?? implicitDatasetRange)) {
      return;
    }
    explicitRange = newRange;
  }

  _onDragStart(DragStartDetails details) {
    //
  }

  _onDragEnd(DragEndDetails details) {
    //
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }
}

abstract class SecondaryAxisController extends _AxisController {
  SecondaryAxisController({
    required super.position,
    super.explicitRange,
  });
}
