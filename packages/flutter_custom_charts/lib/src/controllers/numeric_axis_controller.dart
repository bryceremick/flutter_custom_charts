part of flutter_custom_charts;

class PrimaryNumericAxisController extends PrimaryAxisController {
  PrimaryNumericAxisController({
    required this.secondaryAxisControllers,
    super.position = AxisPosition.bottom,
    super.explicitRange,
  }) {
    for (final secondary in secondaryAxisControllers) {
      verifyAxisPositions(position, secondary.position);
      secondary.addListener(notifyListeners);
    }
  }
  // add an axis max value. If set, the axis will not scroll.
  // changing this value is the only time i need to loop through bars
  // to set the primary axis constraints (xMin, xMax)
  //
  // if axis is scrollable, need to know the pixel per unit ratio

  final List<SecondaryNumericAxisController<DynamicBarDataset>>
      secondaryAxisControllers;

  @override
  void paint(
    Canvas canvas, {
    required ConstrainedArea constraints,
  }) {
    // TODO - verify that the explicit range is a subset of the implicit range
    final primaryAxisDatasetRange = _implicitDataRange;
    final primaryAxisCanvasRange = direction == AxisDirection.horizontal
        ? Range(
            min: constraints.xMin,
            max: constraints.xMax,
          )
        : Range(
            min: constraints.yMin,
            max: constraints.yMax,
          );

    if (primaryAxisDatasetRange == null) {
      print('no primary axis dataset range');
      return;
    }

    if (explicitRange != null &&
        !explicitRange!.isWithin(_implicitDataRange!)) {
      throw XYChartException(
        'Explicit range must be a subset of the implicit dataset range. Explicit$explicitRange, Implicit$_implicitDataRange',
      );
    }

    for (final secondaryAxis in secondaryAxisControllers) {
      final secondaryAxisDatasetRange = secondaryAxis._implicitDataRange;
      final secondaryAxisCanvasRange =
          secondaryAxis.direction == AxisDirection.horizontal
              ? Range(
                  min: constraints.xMin,
                  max: constraints.xMax,
                )
              : Range(
                  min: constraints.yMin,
                  max: constraints.yMax,
                );

      if (secondaryAxisDatasetRange == null) {
        print('no secondary axis dataset range');
        continue;
      }

      for (final dataset in secondaryAxis.barDatasets) {
        // Linear transform canvas scroll offset value to dataset range.
        // This is used to determine the first bar to paint.
        final primaryAxisDatasetMinPosition = linearTransform(
          _scrollOffset,
          rangeA: primaryAxisCanvasRange,
          rangeB: explicitRange ?? primaryAxisDatasetRange,
        );

        // Linear transform canvas range max value to dataset range.
        // This is used to determine when to stop painting bars
        final primaryAxisDatasetMaxPosition = linearTransform(
          primaryAxisCanvasRange.max,
          rangeA: primaryAxisCanvasRange,
          rangeB: explicitRange ?? primaryAxisDatasetRange,
        );

        // binary search for the first bar to paint
        print(Range(
            min: primaryAxisDatasetMinPosition,
            max: primaryAxisDatasetMaxPosition));
        int? index = dataset._indexAt(primaryAxisDatasetMinPosition);

        // if scroll offset is outside the dataset range, do not paint
        // this dataset.
        if (index == null) {
          print('scroll offset is outside the dataset range');
          break;
        }

        // paint bars within chart viewport
        while (dataset.data[index!].primaryAxisMin <=
            primaryAxisDatasetMaxPosition) {
          final bar = dataset.data[index];
          final barConstraints = translateBarToCanvas(
            primaryAxisBarRange:
                Range(min: bar.primaryAxisMin, max: bar.primaryAxisMax),
            secondaryAxisBarRange:
                Range(min: bar.secondaryAxisMin, max: bar.secondaryAxisMax),
            primaryAxisDatasetRange: explicitRange ?? primaryAxisDatasetRange,
            secondaryAxisDatasetRange:
                secondaryAxis.explicitRange ?? secondaryAxisDatasetRange,
            primaryAxisPosition: position,
            secondaryAxisPosition: secondaryAxis.position,
            constraints: constraints,
          );
          bar.paint(canvas, constraints: barConstraints);
          index++;
          if (index >= dataset.data.length) break;
//           print('''
// $index
// primaryAxisBarRange: ${Range(min: bar.primaryAxisMin, max: bar.primaryAxisMax)}
// secondaryAxisBarRange: ${Range(min: bar.secondaryAxisMin, max: bar.secondaryAxisMax)}
// Transformed: $barConstraints
// -------------------------
// ''');
        }
      }
    }
  }

  Range? get _implicitDataRange {
    Range? range;
    for (final secondaryAxis in secondaryAxisControllers) {
      for (final dataset in secondaryAxis.barDatasets) {
        if (dataset._primaryAxisRange != null) {
          range ??= dataset._primaryAxisRange;
          range!.min = min(range.min, dataset._primaryAxisRange!.min);
          range.max = max(range.max, dataset._primaryAxisRange!.max);
        }
      }
    }

    return range;
  }

  void zoomTo(Range to, Duration duration, Curve curve) {
    if (_implicitDataRange == null) {
      return;
    }

    if (!to.isWithin(_implicitDataRange!)) {
      throw XYChartException(
        'Desired range must be a subset of the implicit dataset range. Desired$to, Implicit$_implicitDataRange',
      );
    }

    final controller = AnimationController(
      vsync: this,
      duration: duration,
    );
    _zoomAnimation?.stop();
    _zoomAnimation = ChartAnimation(
      controller: controller,
      curve: curve,
      onUpdate: (value) {
        final newRange = Range(
          min: linearTransform(
            value,
            rangeA: Range(min: 0, max: 1),
            rangeB: Range(
              min: explicitRange != null
                  ? explicitRange!.min
                  : _implicitDataRange!.min,
              max: to.min,
            ),
          ),
          max: linearTransform(
            value,
            rangeA: Range(min: 0, max: 1),
            rangeB: Range(
              min: explicitRange != null
                  ? explicitRange!.max
                  : _implicitDataRange!.max,
              max: to.max,
            ),
          ),
        );
        explicitRange = newRange;
      },
    );

    _zoomAnimation!.start();
  }

  @override
  void dispose() {
    super.dispose();
    for (final secondary in secondaryAxisControllers) {
      secondary.dispose();
    }
  }
}

class SecondaryNumericAxisController<T extends BarDataset>
    extends SecondaryAxisController {
  SecondaryNumericAxisController({
    required this.barDatasets,
    required super.position,
    this.type = AxisDistanceType.auto,
    super.explicitRange,
  }) {
    for (final dataset in barDatasets) {
      dataset.addListener(notifyListeners);
    }
  }

  final List<T> barDatasets;
  final AxisDistanceType type;

  Range? get _implicitDataRange {
    Range? range;
    for (final dataset in barDatasets) {
      if (dataset._secondaryAxisRange != null) {
        range ??= dataset._secondaryAxisRange;
        range!.min = min(range.min, dataset._secondaryAxisRange!.min);
        range.max = max(range.max, dataset._secondaryAxisRange!.max);
      }
    }
    return range;
  }

  @override
  void dispose() {
    super.dispose();
    for (final dataset in barDatasets) {
      dataset.dispose();
    }
  }
}
