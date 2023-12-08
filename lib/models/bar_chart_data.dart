import 'package:flutter/widgets.dart';
import 'package:three_dimensional_bar_chart/widgets/entities/bar.dart';
import 'package:three_dimensional_bar_chart/widgets/entities/line.dart';

/// [pixel] - The constraint of the bar is the pixel value of [Bar.width] or [Bar.height].
///
/// [percentage] - The constraint of the bar is the percentage value of [Bar.width] or [Bar.height].
///
/// [auto] - All bars have equal constraints, and consume 100% of the available space.
/// e.g. If there are 5 bars, each bar will consume 20% of the entire chart
/// width/height constraint.
enum BarConstraintMode {
  pixel,
  percentage,
  auto,
}

class OffsetY {
  const OffsetY({
    required this.upper,
    required this.lower,
  });

  final double upper;
  final double lower;
}

class BarChartController<T extends Bar> extends ChangeNotifier {
  BarChartController({
    required List<T> bars,
    List<Line> lines = const [],
    BarConstraintMode barWidthType = BarConstraintMode.auto,
    EdgeInsets padding = const EdgeInsets.all(0),
    double gap = 15,
  }) {
    _bars = bars;
    _gap = gap;
    _lines = lines;
    _barWidthType = barWidthType;
    _padding = padding;
  }

  late BarConstraintMode _barWidthType;
  late double _gap;
  late List<T> _bars;
  late List<Line> _lines;
  late EdgeInsets _padding;

  List<T> get bars => _bars;
  List<Line> get lines => _lines;
  double get gap => _gap;
  BarConstraintMode get barWidthType => _barWidthType;
  EdgeInsets get padding => _padding;
  double get totalBarsWidth =>
      bars.map((e) => e.width!).reduce((value, element) => value + element);

  set bars(List<T> bars) {
    _bars = bars;
    notifyListeners();
  }

  set gap(double gap) {
    _gap = gap;
    notifyListeners();
  }

  set barWidthType(BarConstraintMode barWidthType) {
    _barWidthType = barWidthType;
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

  void clear() {
    _bars.clear();
    notifyListeners();
  }

  void repaint() {
    notifyListeners();
  }
}
