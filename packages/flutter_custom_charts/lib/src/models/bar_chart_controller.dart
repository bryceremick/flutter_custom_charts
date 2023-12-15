part of flutter_custom_charts;

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
  late AxisDistanceType _xAxisType;
  late AxisDistanceType _yAxisType;
  double? _explicitChartMax;
  double? _explicitChartMin;
  late double _gap;
  late List<T> _bars;
  late List<Line> _lines;
  late EdgeInsets _padding;
  double _xScrollOffset = 0;
  ConstrainedArea chartConstraints = const ConstrainedArea.empty();

  List<T> get bars => _bars;
  List<Line> get lines => _lines;
  double get gap => _gap;
  AxisDistanceType get xAxisType => _xAxisType;
  AxisDistanceType get yAxisType => _yAxisType;
  EdgeInsets get padding => _padding;
  double get xScrollOffset => _xScrollOffset;

  double get xScrollOffsetMax =>
      (((totalBarsWidth + (gap * (bars.length - 1))) * -1) +
          chartConstraints.width);
  double get xScrollOffsetPercentage => xScrollOffset / xScrollOffsetMax;
  double get totalBarsWidth =>
      bars.map((e) => e.width!).reduce((value, element) => value + element);
  double get implicitChartMax => bars.map((e) => e.yMax).reduce(max);
  double get implicitChartMin => bars.map((e) => e.yMin).reduce(min);
  double? get explicitChartMax => _explicitChartMax;
  double? get explicitChartMin => _explicitChartMin;
  double get chartUpperBound => explicitChartMax != null
      ? max(explicitChartMax!, implicitChartMax)
      : implicitChartMax;
  double get chartLowerBound => explicitChartMin != null
      ? min(explicitChartMin!, implicitChartMin)
      : implicitChartMin;

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }

  set bars(List<T> bars) {
    _bars = bars;
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

  void add(T newBar) {
    _bars.add(newBar);
    notifyListeners();
  }

  void addAll(List<T> newBars) {
    _bars.addAll(newBars);
    notifyListeners();
  }

  void insert(int index, T newBar) {
    _bars.insert(index, newBar);
    notifyListeners();
  }

  void remove(int index) {
    _bars.removeAt(index);
    notifyListeners();
  }

  void replace(int index, T newBar) {
    _bars[index] = newBar;
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
    notifyListeners();
  }

  void repaint() {
    notifyListeners();
  }
}
