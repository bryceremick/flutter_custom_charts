part of flutter_custom_charts;

class AxisDetails {
  AxisDetails({
    required this.stepLabelFormatter,
    this.crossAxisPixelSize = 32,
    this.name,
    this.nameLabelStyle = const TextStyle(fontSize: 12, color: Colors.white),
    this.stepLabelStyle = const TextStyle(fontSize: 12, color: Colors.white),
  });

  final String? name;
  final TextStyle nameLabelStyle;
  final TextStyle stepLabelStyle;
  final String Function(double value) stepLabelFormatter;
  final double crossAxisPixelSize;
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

  void Function(Range?)? _onExplicitRangeChange;

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

  void _paintAxisDetails(
    Canvas canvas, {
    required ConstrainedArea constraints,
    required AxisDetails details,
    required Range datasetRange,
    required Color fill,
    required bool isInverted,
  }) {
    final steps = datasetRange.generateSteps(4);
    final mainAlignmentRange = direction == AxisDirection.horizontal
        ? Range(
            min: constraints.xMin,
            max: constraints.xMax,
          )
        : Range(
            min: constraints.yMin,
            max: constraints.yMax,
          );
    final crossAlignmentRange = direction == AxisDirection.horizontal
        ? Range(
            min: constraints.yMin,
            max: constraints.yMax,
          )
        : Range(
            min: constraints.xMin,
            max: constraints.xMax,
          );

    // background
    paintRectangle(
      canvas,
      constraints: constraints,
      fill: fill,
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

      double mainAlignmentRangeValue = linearTransform(
        step,
        rangeA: isInverted ? datasetRange.inverted() : datasetRange,
        // rangeA: datasetRange,
        rangeB: mainAlignmentRange,
      );

      final labelAdjustmentFactor = (direction == AxisDirection.horizontal
          ? stepLabelPainter.width
          : stepLabelPainter.height);

      // prevent painting step label out of bounds
      if (mainAlignmentRangeValue >= mainAlignmentRange.max) {
        mainAlignmentRangeValue =
            mainAlignmentRange.max - labelAdjustmentFactor;
      } else if (mainAlignmentRangeValue <= mainAlignmentRange.min) {
        mainAlignmentRangeValue = mainAlignmentRange.min;
      } else {
        mainAlignmentRangeValue -= labelAdjustmentFactor / 2;
      }

      // center in cross alignment range (for centering label)
      final crossAlignmentRangeValue =
          crossAlignmentRange.midpoint() - (stepLabelPainter.height / 2);

      final stepLabelOffset = direction == AxisDirection.horizontal
          ? Offset(mainAlignmentRangeValue, crossAlignmentRangeValue)
          : Offset(crossAlignmentRangeValue, mainAlignmentRangeValue);

      stepLabelPainter.paint(canvas, stepLabelOffset);
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
    super.explicitRange,
    super.onExplicitRangeChange,
  });

  final bool isScrollable;
  final Range? scrollableRange;
  ChartAnimation? _zoomAnimation;
  Range? get _implicitDataRange => null;

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
