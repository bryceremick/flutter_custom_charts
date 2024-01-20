part of flutter_custom_charts;

abstract class _AxisController extends ChangeNotifier {
  _AxisController({
    required this.position,
    Range? explicitRange,
  }) {
    _explicitRange = explicitRange;
  }

  final AxisPosition position;
  Range? _explicitRange;

  Range? get explicitRange => _explicitRange;
  AxisDirection get direction =>
      position == AxisPosition.left || position == AxisPosition.right
          ? AxisDirection.vertical
          : AxisDirection.horizontal;

  set explicitRange(Range? range) {
    if (range != _explicitRange) {
      _explicitRange = range;
      notifyListeners();
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
      if (details.delta.dy != 0) {
        return;
      }

      delta = calculateDragDelta(
        details.delta.dx,
        canvasRange: Range(min: constraints.xMin, max: constraints.xMax),
        implicitDatasetRange: implicitDatasetRange,
        explicitDatasetRange: explicitRange ?? implicitDatasetRange,
      );
    }

    if (direction == AxisDirection.vertical) {
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
