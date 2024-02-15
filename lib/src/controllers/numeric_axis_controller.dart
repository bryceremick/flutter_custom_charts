part of flutter_custom_charts;

const _onTapGesturePixelSearchTolerance = 20;

class PrimaryNumericAxisController<T extends Bar, K extends Point>
    extends PrimaryAxisController {
  PrimaryNumericAxisController({
    required this.secondaryAxisControllers,
    super.position = AxisPosition.bottom,
    super.isScrollable = true,
    super.scrollableRange,
    super.explicitRange,
    super.onExplicitRangeChange,
    super.barDetailsSpacing,
    this.details,
    this.onTap,
  }) {
    for (final secondary in secondaryAxisControllers) {
      verifyAxisPositions(position, secondary.position);
      secondary.addListener(notifyListeners);
    }
  }

  final List<SecondaryNumericAxisController<T, K>> secondaryAxisControllers;
  AxisDetails? details;

  void Function(
    List<DatasetEntity<T>> bars,
    List<DatasetEntity<K>> points,
  )? onTap;

  @override
  void paint(
    Canvas canvas, {
    required ConstrainedArea constraints,
  }) {
    _allocateConstraints(constraints);
    final clippedArea = determineClippedArea(
      constraints: super.constraints,
      position: position,
      barSpacingAbove: barDetailsSpacing?.spaceAbove,
      barSpacingBelow: barDetailsSpacing?.spaceBelow,
    );
    canvas.save();
    canvas.clipRect(
      Rect.fromLTRB(
        clippedArea.xMin,
        clippedArea.yMin,
        clippedArea.xMax,
        clippedArea.yMax,
      ),
    );
    _paintChartGrid(canvas);
    _paintChartData(canvas);
    canvas.restore();
    _paintChartAxesDetails(canvas);
  }

  void _paintChartData(Canvas canvas) {
    if (_implicitPrimaryAxisDataRange == null) {
      return;
    }

    final primaryAxisCanvasRange =
        _getMainAlignmentCanvasRange(super.constraints);

    if (explicitRange != null &&
        !explicitRange!
            .isWithin(scrollableRange ?? _implicitPrimaryAxisDataRange!)) {
      throw XYChartException(
        'Explicit range must be a subset of the implicit dataset range. Explicit$explicitRange, Implicit${scrollableRange ?? _implicitPrimaryAxisDataRange}',
      );
    }

    final primaryAxisDataSetRange = Range(
      min: linearTransform(
        primaryAxisCanvasRange.min,
        rangeA: primaryAxisCanvasRange,
        rangeB: explicitRange ?? _implicitPrimaryAxisDataRange!,
      ),
      max: linearTransform(
        primaryAxisCanvasRange.max,
        rangeA: primaryAxisCanvasRange,
        rangeB: explicitRange ?? _implicitPrimaryAxisDataRange!,
      ),
    );

    for (final secondaryAxis in secondaryAxisControllers) {
      final secondaryAxisDatasetRange =
          secondaryAxis._implicitSecondaryAxisDataRange;
      if (secondaryAxisDatasetRange == null) {
        continue;
      }

      // paint bars
      for (final dataset in secondaryAxis.barDatasets) {
        if (dataset._isHidden) {
          continue;
        }

        // binary search for the first bar to paint in viewport
        int? index = dataset._firstIndexWithin(primaryAxisDataSetRange);
        if (index == null) {
          // print('NULL INDEX');
          // print('----------------------');
          continue;
        }

        // print('----------------------');

        // paint bars within chart viewport
        while (dataset._data[index!].primaryAxisMin <=
            (primaryAxisDataSetRange.max + 1)) {
          final bar = dataset._data[index];
          final barConstraints = translateBarToCanvas(
            primaryAxisBarRange:
                Range(min: bar.primaryAxisMin, max: bar.primaryAxisMax),
            secondaryAxisBarRange:
                Range(min: bar.secondaryAxisMin, max: bar.secondaryAxisMax),
            primaryAxisDatasetRange:
                explicitRange ?? _implicitPrimaryAxisDataRange!,
            secondaryAxisDatasetRange:
                secondaryAxis.explicitRange ?? secondaryAxisDatasetRange,
            primaryAxisPosition: position,
            secondaryAxisPosition: secondaryAxis.position,
            constraints: super.constraints,
          );

          ConstrainedArea? detailsAboveConstraints;
          ConstrainedArea? detailsBelowConstraints;

          if (barDetailsSpacing != null) {
            if (barDetailsSpacing!.spaceAbove != null) {
              detailsAboveConstraints = determineBarDetailsSpacingAbove(
                barConstraints: barConstraints,
                position: position,
                spacing: barDetailsSpacing!.spaceAbove!,
              );
            }

            if (barDetailsSpacing!.spaceBelow != null) {
              detailsBelowConstraints = determineBarDetailsSpacingBelow(
                barConstraints: barConstraints,
                position: position,
                spacing: barDetailsSpacing!.spaceBelow!,
              );
            }
          }

          bar.paint(
            canvas,
            constraints: barConstraints,
            detailsAboveConstraints: detailsAboveConstraints,
            detailsBelowConstraints: detailsBelowConstraints,
          );
          index++;
          if (index >= dataset._data.length) break;
        }
      }

      // paint points
      for (final dataset in secondaryAxis.pointDatasets) {
        if (dataset._isHidden) {
          continue;
        }

        // binary search for the first point to paint in viewport
        int? index = dataset._firstIndexWithin(primaryAxisDataSetRange);

        if (index == null) {
          continue;
        }

        // paint points within chart viewport
        while (dataset._data[index!].primaryAxisValue <=
            (primaryAxisDataSetRange.max + 1)) {
          final point = dataset._data[index];
          final translatedPoint = translatePointToCanvas(
            primaryAxisValue: point.primaryAxisValue,
            secondaryAxisValue: point.secondaryAxisValue,
            primaryAxisDatasetRange:
                explicitRange ?? _implicitPrimaryAxisDataRange!,
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
                  explicitRange ?? _implicitPrimaryAxisDataRange!,
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

  void _paintChartAxesDetails(Canvas canvas) {
    if (explicitRange == null && _implicitPrimaryAxisDataRange == null) {
      return;
    }

    // primary axis
    if (details != null) {
      _paintAxisDetails(
        canvas,
        constraints: _axisAreas
            .where((e) => e.position == position && e.axisIndex == 0)
            .first
            .area,
        details: details!,
        datasetRange: explicitRange ?? _implicitPrimaryAxisDataRange!,
        isInverted: false,
      );
    }

    // secondary axes
    for (int i = 0; i < secondaryAxisControllers.length; i++) {
      final secondary = secondaryAxisControllers[i];
      if (secondary.details == null ||
          (secondary.explicitRange == null &&
              secondary._implicitSecondaryAxisDataRange == null)) {
        continue;
      }

      secondary._paintAxisDetails(
        canvas,
        constraints: _axisAreas
            .where((e) => e.position == secondary.position && e.axisIndex == i)
            .first
            .area,
        details: secondary.details!,
        datasetRange: secondary.explicitRange ??
            secondary._implicitSecondaryAxisDataRange!,
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

  void _allocateConstraints(ConstrainedArea canvasConstraints) {
    _axisAreas.clear();
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
          axisIndex: 0,
          position: position,
          area: tmp.difference(canvasConstraints),
        ),
      );
    }

    if (barDetailsSpacing != null && barDetailsSpacing!.spaceAbove != null) {
      canvasConstraints = canvasConstraints.shrink(
        EdgeInsets.only(
          left: position == AxisPosition.right
              ? barDetailsSpacing!.spaceAbove!
              : 0,
          top: position == AxisPosition.bottom
              ? barDetailsSpacing!.spaceAbove!
              : 0,
          right: position == AxisPosition.left
              ? barDetailsSpacing!.spaceAbove!
              : 0,
          bottom:
              position == AxisPosition.top ? barDetailsSpacing!.spaceAbove! : 0,
        ),
      );
    }

    if (barDetailsSpacing != null && barDetailsSpacing!.spaceBelow != null) {
      canvasConstraints = canvasConstraints.shrink(
        EdgeInsets.only(
          left: position == AxisPosition.left
              ? barDetailsSpacing!.spaceBelow!
              : 0,
          top:
              position == AxisPosition.top ? barDetailsSpacing!.spaceBelow! : 0,
          right: position == AxisPosition.right
              ? barDetailsSpacing!.spaceBelow!
              : 0,
          bottom: position == AxisPosition.bottom
              ? barDetailsSpacing!.spaceBelow!
              : 0,
        ),
      );
    }

    // secondary axes
    for (int i = 0; i < secondaryAxisControllers.length; i++) {
      final secondary = secondaryAxisControllers[i];
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
            axisIndex: i,
            position: secondary.position,
            area: tmp.difference(canvasConstraints),
          ),
        );
      }
    }

    final primaryAxisAreaIndex = _axisAreas.indexWhere(
      (e) => e.position == position && e.axisIndex == 0,
    );

    // shrink primary axis according to secondary axes sizes
    if (primaryAxisAreaIndex >= 0) {
      final shrunkenPrimaryAxisArea =
          _axisAreas[primaryAxisAreaIndex].area.shrink(
                EdgeInsets.only(
                  left: direction == AxisDirection.horizontal
                      ? _axisAreas
                          .where((e) => e.position == AxisPosition.left)
                          .map((e) => e.area.width)
                          .fold(0, (a, b) => a + b)
                      : 0,
                  top: direction == AxisDirection.vertical
                      ? _axisAreas
                          .where((e) => e.position == AxisPosition.top)
                          .map((e) => e.area.height)
                          .fold(0, (a, b) => a + b)
                      : 0,
                  right: direction == AxisDirection.horizontal
                      ? _axisAreas
                          .where((e) => e.position == AxisPosition.right)
                          .map((e) => e.area.width)
                          .fold(0, (a, b) => a + b)
                      : 0,
                  bottom: direction == AxisDirection.vertical
                      ? _axisAreas
                          .where((e) => e.position == AxisPosition.bottom)
                          .map((e) => e.area.height)
                          .fold(0, (a, b) => a + b)
                      : 0,
                ),
              );
      _axisAreas[primaryAxisAreaIndex].area = shrunkenPrimaryAxisArea;
    }
    super.constraints = canvasConstraints;
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

  @override
  Range? get _implicitSecondaryAxisDataRange {
    Range? range;
    for (final secondaryAxis in secondaryAxisControllers) {
      final secondaryAxisRange = secondaryAxis._implicitSecondaryAxisDataRange;
      if (secondaryAxisRange != null) {
        range ??= secondaryAxisRange;
        range.min = math.min(range.min, secondaryAxisRange.min);
        range.max = math.max(range.max, secondaryAxisRange.max);
      }
    }

    return range;
  }

  @override
  void _onTapDown(TapDownDetails details) {
    if (onTap == null ||
        _implicitPrimaryAxisDataRange == null ||
        _implicitSecondaryAxisDataRange == null) {
      return;
    }

    List<DatasetEntity<T>> bars = [];
    List<DatasetEntity<K>> points = [];

    final primaryAxisCanvasRange =
        super.constraints.primaryAxisRange(direction);
    final primaryAxisDatasetRange =
        explicitRange ?? _implicitPrimaryAxisDataRange!;

    final secondaryAxisCanvasRange =
        super.constraints.secondaryAxisRange(position);
    final secondaryAxisDatasetRange = _implicitSecondaryAxisDataRange!;

    final translatedGestureX = linearTransform(
      details.localPosition.dx,
      rangeA: primaryAxisCanvasRange,
      rangeB: primaryAxisDatasetRange,
    );
    final translatedGestureY = linearTransform(
      details.localPosition.dy,
      rangeA: secondaryAxisCanvasRange,
      rangeB: secondaryAxisDatasetRange,
    );

    final translatedGestureXOffsetMin = linearTransform(
      details.localPosition.dx - _onTapGesturePixelSearchTolerance,
      rangeA: primaryAxisCanvasRange,
      rangeB: primaryAxisDatasetRange,
    );

    final translatedGestureXOffsetMax = linearTransform(
      details.localPosition.dx + _onTapGesturePixelSearchTolerance,
      rangeA: primaryAxisCanvasRange,
      rangeB: primaryAxisDatasetRange,
    );

    for (final secondaryAxis in secondaryAxisControllers) {
      for (final dataset in secondaryAxis.barDatasets) {
        final result = dataset._entitiesContaining(
          Offset(
            translatedGestureX,
            translatedGestureY,
          ),
        );
        if (result.isNotEmpty) {
          bars.addAll(result);
        }
      }

      for (final dataset in secondaryAxis.pointDatasets) {
        final result = dataset._entitiesWithin(
          Range(
            min: translatedGestureXOffsetMin,
            max: translatedGestureXOffsetMax,
          ),
        );
        if (result.isNotEmpty) {
          points.addAll(result);
        }
      }
    }

    if (bars.isEmpty && points.isEmpty) {
      return;
    }

    onTap!.call(bars, points);
  }

  /// Animates the axis to the desired range. If [to] is null, the axis will animate to the default range
  void animateTo({
    required Range? to,
    Duration duration = const Duration(seconds: 1),
    Curve curve = Curves.linear,
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

class SecondaryNumericAxisController<T extends Bar, K extends Point>
    extends SecondaryAxisController {
  SecondaryNumericAxisController({
    this.barDatasets = const [],
    this.pointDatasets = const [],
    required super.position,
    super.explicitRange,
    this.details,
  }) {
    for (final dataset in barDatasets) {
      dataset._plottableDataset.addListener(notifyListeners);
    }
  }

  AxisDetails? details;
  final List<BarDataset<T>> barDatasets;
  final List<PointDataset<K>> pointDatasets;

  Range? get __implicitBarPrimaryAxisRange {
    Range? range;
    for (final dataset in barDatasets) {
      final primaryAxisRange = dataset.primaryAxisRange;
      if (primaryAxisRange != null) {
        range ??= primaryAxisRange;
        range.min = math.min(range.min, primaryAxisRange.min);
        range.max = math.max(range.max, primaryAxisRange.max);
      }
    }
    return range;
  }

  Range? get __implicitBarSecondaryAxisRange {
    Range? range;
    for (final dataset in barDatasets) {
      final secondaryAxisRange = dataset.secondaryAxisRange;
      if (secondaryAxisRange != null) {
        range ??= secondaryAxisRange;
        range.min = math.min(range.min, secondaryAxisRange.min);
        range.max = math.max(range.max, secondaryAxisRange.max);
      }
    }
    return range;
  }

  Range? get __implicitPointPrimaryAxisRange {
    Range? range;
    for (final dataset in pointDatasets) {
      final primaryAxisRange = dataset.primaryAxisRange;
      if (primaryAxisRange != null) {
        range ??= primaryAxisRange;
        range.min = math.min(range.min, primaryAxisRange.min);
        range.max = math.max(range.max, primaryAxisRange.max);
      }
    }
    return range;
  }

  Range? get __implicitPointSecondaryAxisRange {
    Range? range;
    for (final dataset in pointDatasets) {
      final secondaryAxisRange = dataset.secondaryAxisRange;
      if (secondaryAxisRange != null) {
        range ??= secondaryAxisRange;
        range.min = math.min(range.min, secondaryAxisRange.min);
        range.max = math.max(range.max, secondaryAxisRange.max);
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
    for (final dataset in barDatasets) {
      dataset._plottableDataset.dispose();
    }
  }
}
