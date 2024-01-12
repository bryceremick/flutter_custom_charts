part of flutter_custom_charts;

// This is the number of bars that get painted outside of the visible area
// on both sides of the chart. This is to give the chart a "scrolling" effect
const int _horizontalBarScrollPadding = 1;

class _BarMetrics {
  _BarMetrics({
    required this.totalWidth,
    required this.yMax,
    required this.yMin,
  });
  final double totalWidth;
  final double yMax;
  final double yMin;
}

class BarChartController<T extends Bar> extends ChangeNotifier
    implements TickerProvider {
  BarChartController({
    required List<T> bars,
    List<Line> lines = const [],
    AxisDistanceType xAxisType = AxisDistanceType.auto,
    AxisDistanceType yAxisType = AxisDistanceType.auto,
    EdgeInsets padding = const EdgeInsets.only(bottom: 40),
    double gap = 15,
    double? explicitChartMax,
    double? explicitChartMin,
    double? staticBarWidth,
    AnimationDetails? barAnimationDetails,
  }) {
    _bars = bars;
    _gap = gap;
    _lines = lines;
    _xAxisType = xAxisType;
    _yAxisType = yAxisType;
    _padding = padding;
    _explicitChartMax = explicitChartMax;
    _explicitChartMin = explicitChartMin;
    _staticBarWidth = staticBarWidth;
    _chartConstraints = const ConstrainedArea.empty();
    _calculateBarMetrics(bars);

    _scrollAnimation = ChartAnimation(
      controller: AnimationController(
        vsync: this,
        duration: const Duration(seconds: 1),
      ),
      curve: Curves.easeOutCubic,
      onUpdate: (value) {},
    );

    if (barAnimationDetails != null) {
      barAnimation = ChartAnimation(
        controller: AnimationController(
          vsync: this,
          duration: barAnimationDetails.duration,
        ),
        curve: barAnimationDetails.curve,
        onUpdate: (value) => notifyListeners(),
      );
      barAnimation!.start();
    }
  }

  ChartAnimation? barAnimation;
  late final ChartAnimation _scrollAnimation;
  late AxisDistanceType _xAxisType;
  late AxisDistanceType _yAxisType;
  double? _explicitChartMax;
  double? _explicitChartMin;
  double? _staticBarWidth;
  late double _gap;
  late List<T> _bars;
  late List<Line> _lines;
  late EdgeInsets _padding;
  double _xScrollOffset = 0;
  late ConstrainedArea _chartConstraints;

  double _totalBarsWidth = 0;
  double _implicitChartMax = 0;
  double _implicitChartMin = 0;

  List<T> get bars => _bars;
  List<Line> get lines => _lines;
  double get gap => _gap;
  AxisDistanceType get xAxisType => _xAxisType;
  AxisDistanceType get yAxisType => _yAxisType;
  EdgeInsets get padding => _padding;
  double get xScrollOffset => _xScrollOffset;
  ChartAnimation get scrollAnimation => _scrollAnimation;

  ConstrainedArea get chartConstraints => _chartConstraints;
  ConstrainedArea get currentTranslation {
    return ConstrainedArea(
      xMin: -_xScrollOffset,
      xMax: -_xScrollOffset + _chartConstraints.width,
      yMin: chartConstraints.yMin,
      yMax: chartConstraints.yMax,
    );
  }

  // TODO - this is not correct for auto and percentage
  // this also assumes there will be no scrolling
  double get totalAvailableBarSpace =>
      (_chartConstraints.width - ((_bars.length - 1) * _gap));

  double get xScrollOffsetMax => _bars.isNotEmpty
      ? (_bars.last.constraints.xMax - chartConstraints.xMax) * -1
      : -_chartConstraints.xMax;
  double get xScrollOffsetPercentage => xScrollOffset / xScrollOffsetMax;
  double get implicitChartMax => _implicitChartMax;
  double get implicitChartMin => _implicitChartMin;
  double? get explicitChartMax => _explicitChartMax;
  double? get explicitChartMin => _explicitChartMin;

  double get chartUpperBound => explicitChartMax != null
      ? max(_explicitChartMax!, _implicitChartMax)
      : _implicitChartMax;
  double get chartLowerBound => explicitChartMin != null
      ? min(_explicitChartMin!, _implicitChartMin)
      : _implicitChartMin;

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }

  void _calculateBarMetrics(
    List<T> bars, {
    bool isRemoved = false,
    bool shouldReset = false,
  }) {
    if (shouldReset) {
      _resetBarMetrics();
    }

    final metrics = _reduceBarMetrics(bars);
    if (!isRemoved) {
      _totalBarsWidth += metrics.totalWidth;
      _implicitChartMax = max(_implicitChartMax, metrics.yMax);
      _implicitChartMin = min(_implicitChartMin, metrics.yMin);
    } else {
      _totalBarsWidth -= metrics.totalWidth;
      if (metrics.yMax == _implicitChartMax) {
        _implicitChartMax = _bars.map((e) => e.yMax).reduce(max);
      }
      if (metrics.yMin == _implicitChartMin) {
        _implicitChartMin = _bars.map((e) => e.yMin).reduce(min);
      }
    }
  }

  _BarMetrics _reduceBarMetrics(List<T> bars) {
    if (bars.isEmpty) {
      return _BarMetrics(
        totalWidth: 0,
        yMax: 0,
        yMin: 0,
      );
    }

    return _BarMetrics(
      totalWidth: bars
          .map((e) => e.width ?? 0)
          .reduce((value, element) => value + element),
      yMax: bars.map((e) => e.yMax).reduce(max),
      yMin: bars.map((e) => e.yMin).reduce(min),
    );
  }

  void _resetBarMetrics() {
    _bars = [];
    _totalBarsWidth = 0;
    _implicitChartMax = 0;
    _implicitChartMin = 0;
  }

  set bars(List<T> bars) {
    _bars = bars;
    _calculateBarMetrics(bars, shouldReset: true);
    notifyListeners();
  }

  set gap(double gap) {
    _gap = gap;
    notifyListeners();
  }

  set xAxisType(AxisDistanceType type) {
    _xAxisType = type;
    notifyListeners();
  }

  set yAxisType(AxisDistanceType type) {
    _yAxisType = type;
    notifyListeners();
  }

  set lines(List<Line> lines) {
    this.lines = lines;
    notifyListeners();
  }

  set padding(EdgeInsets padding) {
    _padding = padding;
    notifyListeners();
  }

  set xScrollOffset(double xScrollOffset) {
    _xScrollOffset = xScrollOffset;
    notifyListeners();
  }

  set explicitChartMax(double? explicitChartMax) {
    _explicitChartMax = explicitChartMax;
    notifyListeners();
  }

  set explicitChartMin(double? explicitChartMin) {
    _explicitChartMin = explicitChartMin;
    notifyListeners();
  }

  void _setChartConstraints(ConstrainedArea constraints) {
    if (constraints == _chartConstraints) {
      return;
    }
    _chartConstraints = constraints;
    _setAllBarConstraints();
  }

  int get _firstPaintedBarIndex {
    int left = 0;
    int right = _bars.length - 1;
    final x = -xScrollOffset + chartConstraints.xMin;
    int i = 0;

    // if all bars are same width, do not use binary search
    if (_staticBarWidth != null) {
      final totalBarWidth = _staticBarWidth! + _gap;
      return max((-xScrollOffset / totalBarWidth).floor(), 0);
    }

    // binary search
    while (left <= right) {
      i++;
      int mid = left + ((right - left) >> 1);
      double xMin = _bars[mid].constraints.xMin;
      double xMax = _bars[mid].constraints.xMax + _gap;

      if (xMin <= x && x <= xMax) {
        // print('iterations: $i');
        return mid;
      } else if (x < xMin) {
        right = mid - 1;
      } else {
        left = mid + 1;
      }
    }

    throw XYChartException('Could not find first painted bar index');
  }

  double _calculateBarWidth(int index) {
    switch (_xAxisType) {
      case AxisDistanceType.auto:
        return totalAvailableBarSpace / _bars.length;
      case AxisDistanceType.percentage:
        final width =
            _staticBarWidth != null ? _staticBarWidth! : _bars[index].width!;
        return totalAvailableBarSpace * width;
      case AxisDistanceType.pixel:
        return _staticBarWidth != null ? _staticBarWidth! : _bars[index].width!;
    }
  }

  // void _setAllBarConstraints() {
  //   double dx = _chartConstraints.xMin;
  //   for (int i = 0; i < _bars.length; i++) {
  //     final width = _calculateBarWidth(i).roundToDouble();
  //     _bars[i].constraints = ConstrainedArea(
  //       xMin: dx,
  //       xMax: dx + width,
  //       yMin: _chartConstraints.yMin,
  //       yMax: _chartConstraints.yMax,
  //     );
  //     dx += (width + _gap);
  //   }
  // }

  void _setAllBarConstraints() {
    double dx = _chartConstraints.xMin;
    for (int i = 0; i < _bars.length; i++) {
      final width = _calculateBarWidth(i).roundToDouble();
      _bars[i].constraints = ConstrainedArea(
        xMin: dx,
        xMax: dx + width,
        yMin: _chartConstraints.yMin,
        yMax: _chartConstraints.yMax,
      );
      dx += (width + _gap);
    }
  }

  void _setBarConstraints(int index) {
    final dx = index == 0
        ? _chartConstraints.xMin
        : _bars[index - 1].constraints.xMax + _gap;
    final width = _calculateBarWidth(index).roundToDouble();
    _bars[index].constraints = ConstrainedArea(
      xMin: dx,
      xMax: dx + width,
      yMin: _chartConstraints.yMin,
      yMax: _chartConstraints.yMax,
    );
  }

  // (int, int) get firstAndLastPaintedBarIndexes {
  //   final totalBarWidth = _barWidthPixels + _gap;
  //   final translation = currentTranslation;

  //   int first = max(
  //       ((translation.xMin / totalBarWidth).floor()) -
  //           _horizontalBarScrollPadding,
  //       0);
  //   int last = min(
  //       ((translation.xMax / totalBarWidth).ceil()) +
  //           _horizontalBarScrollPadding,
  //       _bars.length - 1);

  //   return (first, last);
  // }

  void add(T newBar) {
    _bars.add(newBar);
    _calculateBarMetrics([newBar]);
    notifyListeners();
  }

  void addAll(List<T> newBars) {
    _bars.addAll(newBars);
    _calculateBarMetrics(newBars);
    notifyListeners();
  }

  void insert(int index, T newBar) {
    _bars.insert(index, newBar);
    _calculateBarMetrics([newBar]);
    notifyListeners();
  }

  void remove(int index) {
    final bar = _bars.removeAt(index);
    _calculateBarMetrics([bar], isRemoved: true);
    notifyListeners();
  }

  void replace(int index, T newBar) {
    _bars[index] = newBar;
    _calculateBarMetrics([newBar], isRemoved: true);
    _calculateBarMetrics([newBar]);
    notifyListeners();
  }

  void scrollToPercentageX(double percentage) {
    if (percentage > 1) {
      percentage = 1;
    }
    if (percentage < 0) {
      percentage = 0;
    }
    _xScrollOffset = xScrollOffsetMax * percentage;
    notifyListeners();
  }

  void clear() {
    _bars.clear();
    _resetBarMetrics();
    notifyListeners();
  }

  void repaint() {
    notifyListeners();
  }
}
