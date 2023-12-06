import 'package:flutter/widgets.dart';
import 'package:three_dimensional_bar_chart/widgets/bars/bar.dart';

/// [pixel] - The constraint of the bar is the pixel value of [Bar.width].
///
/// [percentage] - The constraint of the bar is the percentage value of [Bar.width].
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
    BarConstraintMode barWidthType = BarConstraintMode.auto,
    BarConstraintMode barHeightType = BarConstraintMode.auto,
    OffsetY offsetY = const OffsetY(upper: 0, lower: 0),
    double gap = 15,
  }) {
    _bars = bars;
    _gap = gap;
    _barWidthType = barWidthType;
    _barHeightType = barHeightType;
    _offsetY = offsetY;
  }

  late BarConstraintMode _barWidthType;
  late BarConstraintMode _barHeightType;
  late double _gap;
  late OffsetY _offsetY;
  late final List<T> _bars;

  List<T> get bars => _bars;
  double get gap => _gap;
  BarConstraintMode get barWidthType => _barWidthType;
  BarConstraintMode get barHeightType => _barHeightType;
  OffsetY get offsetY => _offsetY;

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

  set barHeightType(BarConstraintMode barHeightType) {
    _barHeightType = barHeightType;
    notifyListeners();
  }

  set offsetY(OffsetY offsetY) {
    _offsetY = offsetY;
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
