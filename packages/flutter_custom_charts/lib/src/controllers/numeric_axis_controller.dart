part of flutter_custom_charts;

class PrimaryNumericAxisController extends PrimaryAxisController {
  PrimaryNumericAxisController({
    required this.secondaryAxisControllers,
    super.position = AxisPosition.bottom,
    super.isScrollable = true,
    super.scrollableRange,
    super.explicitRange,
    this.details,
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

  AxisDetails? details;
  final List<SecondaryNumericAxisController<DynamicBarDataset>>
      secondaryAxisControllers;

  ConstrainedArea _shrinkConstraints(ConstrainedArea constraints) {
    constraints = constraints.shrink(
      EdgeInsets.only(
        left: position == AxisPosition.left ? details!.crossAxisPixelSize : 0,
        top: position == AxisPosition.top ? details!.crossAxisPixelSize : 0,
        right: position == AxisPosition.right ? details!.crossAxisPixelSize : 0,
        bottom:
            position == AxisPosition.bottom ? details!.crossAxisPixelSize : 0,
      ),
    );
    for (final secondary in secondaryAxisControllers) {
      if (secondary.details != null) {
        constraints = constraints.shrink(
          EdgeInsets.only(
            left: secondary.position == AxisPosition.left
                ? secondary.details!.crossAxisPixelSize
                : 0,
            top: secondary.position == AxisPosition.top
                ? secondary.details!.crossAxisPixelSize
                : 0,
            right: secondary.position == AxisPosition.right
                ? secondary.details!.crossAxisPixelSize
                : 0,
            bottom: secondary.position == AxisPosition.bottom
                ? secondary.details!.crossAxisPixelSize
                : 0,
          ),
        );
      }
    }

    return constraints;
  }

  @override
  void paint(
    Canvas canvas, {
    required ConstrainedArea constraints,
  }) {
    super.constraints = _shrinkConstraints(constraints);
    final primaryAxisDatasetRange = _implicitDataRange;
    final primaryAxisCanvasRange = direction == AxisDirection.horizontal
        ? Range(
            min: super.constraints.xMin,
            max: super.constraints.xMax,
          )
        : Range(
            min: super.constraints.yMin,
            max: super.constraints.yMax,
          );

    if (primaryAxisDatasetRange == null) {
      return;
    }

    if (explicitRange != null &&
        !explicitRange!.isWithin(scrollableRange ?? primaryAxisDatasetRange)) {
      throw XYChartException(
        'Explicit range must be a subset of the implicit dataset range. Explicit$explicitRange, Implicit${scrollableRange ?? _implicitDataRange}',
      );
    }

    for (final secondaryAxis in secondaryAxisControllers) {
      final secondaryAxisDatasetRange = secondaryAxis._implicitDataRange;
      final secondaryAxisCanvasRange =
          secondaryAxis.direction == AxisDirection.horizontal
              ? Range(
                  min: super.constraints.xMin,
                  max: super.constraints.xMax,
                )
              : Range(
                  min: super.constraints.yMin,
                  max: super.constraints.yMax,
                );

      if (secondaryAxisDatasetRange == null) {
        continue;
      }

      for (final dataset in secondaryAxis.barDatasets) {
        final primaryAxisDataSetRange = Range(
          min: linearTransform(
            primaryAxisCanvasRange.min,
            rangeA: primaryAxisCanvasRange,
            rangeB: explicitRange ?? primaryAxisDatasetRange,
          ),
          max: linearTransform(
            primaryAxisCanvasRange.max,
            rangeA: primaryAxisCanvasRange,
            rangeB: explicitRange ?? primaryAxisDatasetRange,
          ),
        );

        // binary search for the first bar to paint
        int? index = dataset._firstIndexWithin(primaryAxisDataSetRange);
        if (index == null) {
          break;
        }

        // paint bars within chart viewport
        while (dataset.data[index!].primaryAxisMin <=
            (primaryAxisDataSetRange.max + 1)) {
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
            constraints: super.constraints,
          );
          bar.paint(canvas, constraints: barConstraints);
//           print('''
// $index
// primaryAxisBarRange: ${Range(min: bar.primaryAxisMin, max: bar.primaryAxisMax)}
// secondaryAxisBarRange: ${Range(min: bar.secondaryAxisMin, max: bar.secondaryAxisMax)}
// Transformed: $barConstraints
// -------------------------
// ''');
          index++;
          if (index >= dataset.data.length) break;
        }
      }
    }

    if (details != null) {
      _paintAxisDetails(
        canvas,
        constraints: determineAxisDetailsConstraints(
          constraints: super.constraints,
          position: position,
          detailsCrossAxisPixelSize: details!.crossAxisPixelSize,
        ),
        details: details!,
        datasetRange: explicitRange ?? primaryAxisDatasetRange,
        fill: Colors.red,
      );
    }

    for (final secondaryAxis in secondaryAxisControllers) {
      if (secondaryAxis.details != null) {
        secondaryAxis._paintAxisDetails(
          canvas,
          constraints: determineAxisDetailsConstraints(
            constraints: super.constraints,
            position: secondaryAxis.position,
            detailsCrossAxisPixelSize:
                secondaryAxis.details!.crossAxisPixelSize,
          ),
          details: secondaryAxis.details!,
          datasetRange:
              secondaryAxis.explicitRange ?? secondaryAxis._implicitDataRange!,
          fill: Colors.red,
        );
      }
    }
  }

  @override
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

    if (!to.isWithin(scrollableRange ?? _implicitDataRange!)) {
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
    super.explicitRange,
    this.details,
  }) {
    for (final dataset in barDatasets) {
      dataset.addListener(notifyListeners);
    }
  }

  AxisDetails? details;
  final List<T> barDatasets;

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
