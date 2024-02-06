part of flutter_custom_charts;

class PrimaryNumericAxisController<T extends BarDataset, K extends PointDataset>
    extends PrimaryAxisController {
  PrimaryNumericAxisController({
    required this.secondaryAxisControllers,
    super.position = AxisPosition.bottom,
    super.isScrollable = true,
    super.scrollableRange,
    super.explicitRange,
    super.onExplicitRangeChange,
    super.detailsAboveSize,
    super.detailsBelowSize,
    this.details,
  }) {
    for (final secondary in secondaryAxisControllers) {
      verifyAxisPositions(position, secondary.position);
      secondary.addListener(notifyListeners);
    }
  }

  AxisDetails? details;
  final List<SecondaryNumericAxisController<T, K>> secondaryAxisControllers;

  @override
  void paint(
    Canvas canvas, {
    required ConstrainedArea constraints,
  }) {
    super.constraints = _assignConstraints(constraints);
    canvas.save();
    canvas.clipRect(
      Rect.fromLTRB(
        super.constraints.xMin,
        super.constraints.yMin,
        super.constraints.xMax,
        super.constraints.yMax,
      ),
    );
    _paintChartGrid(canvas);
    _paintChartData(canvas);
    canvas.restore();
    _paintChartAxesDetails(canvas);
  }

  void _paintChartData(Canvas canvas) {
    final primaryAxisDatasetRange = _implicitPrimaryAxisDataRange;
    if (primaryAxisDatasetRange == null) {
      return;
    }

    final primaryAxisCanvasRange =
        _getMainAlignmentCanvasRange(super.constraints);

    if (explicitRange != null &&
        !explicitRange!.isWithin(scrollableRange ?? primaryAxisDatasetRange)) {
      throw XYChartException(
        'Explicit range must be a subset of the implicit dataset range. Explicit$explicitRange, Implicit${scrollableRange ?? _implicitPrimaryAxisDataRange}',
      );
    }

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

    for (final secondaryAxis in secondaryAxisControllers) {
      final secondaryAxisDatasetRange =
          secondaryAxis._implicitSecondaryAxisDataRange;
      if (secondaryAxisDatasetRange == null) {
        continue;
      }

      // paint bars
      if (secondaryAxis.barDatasets != null) {
        for (final dataset in secondaryAxis.barDatasets!) {
          // binary search for the first bar to paint in viewport
          int? index = dataset._firstIndexWithin(primaryAxisDataSetRange);

          // paint bars within chart viewport
          while (dataset._data[index!].primaryAxisMin <=
              (primaryAxisDataSetRange.max + 1)) {
            final bar = dataset._data[index];
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
            index++;
            if (index >= dataset._data.length) break;
          }
        }
      }

      // paint points
      if (secondaryAxis.pointDatasets != null) {
        for (final dataset in secondaryAxis.pointDatasets!) {
          // binary search for the first point to paint in viewport
          int? index = dataset._firstIndexWithin(primaryAxisDataSetRange);

          // paint points within chart viewport
          while (dataset._data[index!].primaryAxisValue <=
              (primaryAxisDataSetRange.max + 1)) {
            final point = dataset._data[index];
            final translatedPoint = translatePointToCanvas(
              primaryAxisValue: point.primaryAxisValue,
              secondaryAxisValue: point.secondaryAxisValue,
              primaryAxisDatasetRange: explicitRange ?? primaryAxisDatasetRange,
              secondaryAxisDatasetRange:
                  secondaryAxis.explicitRange ?? secondaryAxisDatasetRange,
              primaryAxisPosition: position,
              constraints: super.constraints,
            );

            Offset? translatedNextPoint;
            Color? nextPointFill;

            if (dataset.connectPoints && index < dataset._data.length - 1) {
              final nextPoint = dataset._data[index + 1];
              nextPointFill = nextPoint.fill;
              translatedNextPoint = translatePointToCanvas(
                primaryAxisValue: nextPoint.primaryAxisValue,
                secondaryAxisValue: nextPoint.secondaryAxisValue,
                primaryAxisDatasetRange:
                    explicitRange ?? primaryAxisDatasetRange,
                secondaryAxisDatasetRange:
                    secondaryAxis.explicitRange ?? secondaryAxisDatasetRange,
                primaryAxisPosition: position,
                constraints: super.constraints,
              );
            }

            point.paint(
              canvas,
              canvasRelativePoint: translatedPoint,
              canvasRelativeNextPoint: translatedNextPoint,
              nextPointFill: nextPointFill,
            );
            index++;
            if (index >= dataset._data.length) break;
          }
        }
      }
    }
  }

  void _paintChartAxesDetails(Canvas canvas) {
    if (explicitRange == null && _implicitPrimaryAxisDataRange == null) {
      return;
    }

    if (details != null) {
      _paintAxisDetails(
        canvas,
        constraints: determineAxisDetailsConstraints(
          constraints: super.constraints,
          position: position,
          detailsCrossAxisPixelSize: details!.crossAlignmentPixelSize,
        ),
        details: details!,
        datasetRange: explicitRange ?? _implicitPrimaryAxisDataRange!,
        isInverted: false,
      );
    }

    for (final secondaryAxis in secondaryAxisControllers) {
      if (secondaryAxis.details == null ||
          (secondaryAxis.explicitRange == null &&
              secondaryAxis._implicitSecondaryAxisDataRange == null)) {
        continue;
      }

      secondaryAxis._paintAxisDetails(
        canvas,
        constraints: determineAxisDetailsConstraints(
          constraints: super.constraints,
          position: secondaryAxis.position,
          detailsCrossAxisPixelSize:
              secondaryAxis.details!.crossAlignmentPixelSize,
        ),
        details: secondaryAxis.details!,
        datasetRange: secondaryAxis.explicitRange ??
            secondaryAxis._implicitSecondaryAxisDataRange!,
        isInverted: isSecondaryAxisInverted(position),
      );
    }
  }

  void _paintChartGrid(Canvas canvas) {
    if (explicitRange == null && _implicitPrimaryAxisDataRange == null) {
      return;
    }

    if (details != null) {
      _paintAxisGrid(
        canvas,
        constraints: super.constraints,
        details: details!,
        datasetRange: explicitRange ?? _implicitPrimaryAxisDataRange!,
      );
    }

    for (final secondaryAxis in secondaryAxisControllers) {
      if (secondaryAxis.details == null ||
          (secondaryAxis.explicitRange == null &&
              secondaryAxis._implicitSecondaryAxisDataRange == null)) {
        continue;
      }
      secondaryAxis._paintAxisGrid(
        canvas,
        constraints: super.constraints,
        details: secondaryAxis.details!,
        datasetRange: secondaryAxis.explicitRange ??
            secondaryAxis._implicitSecondaryAxisDataRange!,
      );
    }
  }

  ConstrainedArea _assignConstraints(ConstrainedArea canvasConstraints) {
    // primary axis
    if (details != null) {
      ConstrainedArea tmp = canvasConstraints.copyWith();
      canvasConstraints = canvasConstraints.shrink(
        EdgeInsets.only(
          left: position == AxisPosition.left
              ? details!.crossAlignmentPixelSize
              : 0,
          top: position == AxisPosition.top
              ? details!.crossAlignmentPixelSize
              : 0,
          right: position == AxisPosition.right
              ? details!.crossAlignmentPixelSize
              : 0,
          bottom: position == AxisPosition.bottom
              ? details!.crossAlignmentPixelSize
              : 0,
        ),
      );
      _axisAreas.add(
        _ChartAxisArea(
          position: position,
          area: tmp.difference(canvasConstraints),
        ),
      );
    }

    // secondary axes
    for (final secondary in secondaryAxisControllers) {
      if (secondary.details != null) {
        ConstrainedArea tmp = canvasConstraints.copyWith();
        canvasConstraints = canvasConstraints.shrink(
          EdgeInsets.only(
            left: secondary.position == AxisPosition.left
                ? secondary.details!.crossAlignmentPixelSize
                : 0,
            top: secondary.position == AxisPosition.top
                ? secondary.details!.crossAlignmentPixelSize
                : 0,
            right: secondary.position == AxisPosition.right
                ? secondary.details!.crossAlignmentPixelSize
                : 0,
            bottom: secondary.position == AxisPosition.bottom
                ? secondary.details!.crossAlignmentPixelSize
                : 0,
          ),
        );
        _axisAreas.add(
          _ChartAxisArea(
            position: secondary.position,
            area: tmp.difference(canvasConstraints),
          ),
        );
      }
    }
    return canvasConstraints;
  }

  @override
  Range? get _implicitPrimaryAxisDataRange {
    Range? range;
    for (final secondaryAxis in secondaryAxisControllers) {
      final primaryAxisRange = secondaryAxis._implicitPrimaryAxisDataRange;
      if (primaryAxisRange != null) {
        range ??= primaryAxisRange;
        range.min = math.min(range.min, primaryAxisRange.min);
        range.max = math.max(range.max, primaryAxisRange.max);
      }
    }

    return range;
  }

  /// Animates the axis to the desired range. If [to] is null, the axis will animate to the default range
  void animateTo({
    required Range? to,
    required Duration duration,
    required Curve curve,
  }) {
    if (_implicitPrimaryAxisDataRange == null) {
      return;
    }

    if (to != null &&
        !to.isWithin(scrollableRange ?? _implicitPrimaryAxisDataRange!)) {
      throw XYChartException(
        'Desired range must be a subset of the default axis range. Desired: [$to], Default: [${scrollableRange ?? _implicitPrimaryAxisDataRange!}]',
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
                  : _implicitPrimaryAxisDataRange!.min,
              max: to?.min ??
                  (scrollableRange?.min ?? _implicitPrimaryAxisDataRange!.min),
            ),
          ),
          max: linearTransform(
            value,
            rangeA: Range(min: 0, max: 1),
            rangeB: Range(
              min: explicitRange != null
                  ? explicitRange!.max
                  : _implicitPrimaryAxisDataRange!.max,
              max: to?.max ??
                  (scrollableRange?.max ?? _implicitPrimaryAxisDataRange!.max),
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

class SecondaryNumericAxisController<T extends BarDataset,
    K extends PointDataset> extends SecondaryAxisController {
  SecondaryNumericAxisController({
    this.barDatasets,
    this.pointDatasets,
    required super.position,
    super.explicitRange,
    this.details,
  }) {
    if (barDatasets != null) {
      for (final dataset in barDatasets!) {
        dataset._plottableDataset.addListener(notifyListeners);
      }
    }
  }

  AxisDetails? details;
  final List<T>? barDatasets;
  final List<K>? pointDatasets;

  Range? get __implicitBarPrimaryAxisRange {
    Range? range;
    if (barDatasets != null) {
      for (final dataset in barDatasets!) {
        final primaryAxisRange = dataset.primaryAxisRange;
        if (primaryAxisRange != null) {
          range ??= primaryAxisRange;
          range.min = math.min(range.min, primaryAxisRange.min);
          range.max = math.max(range.max, primaryAxisRange.max);
        }
      }
    }
    return range;
  }

  Range? get __implicitBarSecondaryAxisRange {
    Range? range;
    if (barDatasets != null) {
      for (final dataset in barDatasets!) {
        final secondaryAxisRange = dataset.secondaryAxisRange;
        if (secondaryAxisRange != null) {
          range ??= secondaryAxisRange;
          range.min = math.min(range.min, secondaryAxisRange.min);
          range.max = math.max(range.max, secondaryAxisRange.max);
        }
      }
    }
    return range;
  }

  Range? get __implicitPointPrimaryAxisRange {
    Range? range;
    if (pointDatasets != null) {
      for (final dataset in pointDatasets!) {
        final primaryAxisRange = dataset.primaryAxisRange;
        if (primaryAxisRange != null) {
          range ??= primaryAxisRange;
          range.min = math.min(range.min, primaryAxisRange.min);
          range.max = math.max(range.max, primaryAxisRange.max);
        }
      }
    }
    return range;
  }

  Range? get __implicitPointSecondaryAxisRange {
    Range? range;
    if (pointDatasets != null) {
      for (final dataset in pointDatasets!) {
        final secondaryAxisRange = dataset.secondaryAxisRange;
        if (secondaryAxisRange != null) {
          range ??= secondaryAxisRange;
          range.min = math.min(range.min, secondaryAxisRange.min);
          range.max = math.max(range.max, secondaryAxisRange.max);
        }
      }
    }
    return range;
  }

  Range? get _implicitPrimaryAxisDataRange {
    final barRange = __implicitBarPrimaryAxisRange;
    final pointRange = __implicitPointPrimaryAxisRange;
    if (barRange == null && pointRange == null) {
      return null;
    }
    if (barRange == null) {
      return pointRange;
    }
    if (pointRange == null) {
      return barRange;
    }
    return Range(
      min: math.min(barRange.min, pointRange.min),
      max: math.max(barRange.max, pointRange.max),
    );
  }

  Range? get _implicitSecondaryAxisDataRange {
    final barRange = __implicitBarSecondaryAxisRange;
    final pointRange = __implicitPointSecondaryAxisRange;
    if (barRange == null && pointRange == null) {
      return null;
    }
    if (barRange == null) {
      return pointRange;
    }
    if (pointRange == null) {
      return barRange;
    }
    return Range(
      min: math.min(barRange.min, pointRange.min),
      max: math.max(barRange.max, pointRange.max),
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (barDatasets != null) {
      for (final dataset in barDatasets!) {
        dataset._plottableDataset.dispose();
      }
    }
  }
}
