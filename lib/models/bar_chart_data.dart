import 'package:flutter/widgets.dart';
import 'package:three_dimensional_bar_chart/widgets/entities/bar.dart';
import 'package:three_dimensional_bar_chart/widgets/entities/line.dart';
import 'package:three_dimensional_bar_chart/widgets/entities/painter.dart';

/// [pixel] - The constraint of the bar is the pixel value of [Bar.width] or [Bar.height].
///
/// [percentage] - The constraint of the bar is the percentage value of [Bar.width] or [Bar.height].
///
/// [auto] - All bars have equal constraints, and consume 100% of the available space.
/// e.g. If there are 5 bars, each bar will consume 20% of the entire chart
/// width/height constraint.
enum AxisDistanceType {
  pixel,
  percentage,
  auto,
}

class BarChartController<T extends Bar> extends ChangeNotifier {
  BarChartController({
    required List<T> bars,
    List<Line> lines = const [],
    AxisDistanceType barWidthType = AxisDistanceType.auto,
    EdgeInsets padding = const EdgeInsets.all(0),
    double gap = 15,
  }) {
    _bars = bars;
    _gap = gap;
    _lines = lines;
    _barWidthType = barWidthType;
    _padding = padding;
  }

  late AxisDistanceType _barWidthType;
  late double _gap;
  late List<T> _bars;
  late List<Line> _lines;
  late EdgeInsets _padding;
  double _xScrollOffset = 0;
  ConstrainedArea chartConstraints = const ConstrainedArea.empty();

  List<T> get bars => _bars;
  List<Line> get lines => _lines;
  double get gap => _gap;
  AxisDistanceType get barWidthType => _barWidthType;
  EdgeInsets get padding => _padding;
  double get xScrollOffset => _xScrollOffset;

  double get xScrollOffsetMax =>
      (((totalBarsWidth + (gap * (bars.length - 1))) * -1) +
          chartConstraints.width);
  double get xScrollOffsetPercentage => xScrollOffset / xScrollOffsetMax;
  double get totalBarsWidth =>
      bars.map((e) => e.width!).reduce((value, element) => value + element);
  double get barHeightMax => bars
      .map((e) => e.height.value)
      .reduce((value, element) => value + element);

  set bars(List<T> bars) {
    _bars = bars;
    notifyListeners();
  }

  set gap(double gap) {
    _gap = gap;
    notifyListeners();
  }

  set barWidthType(AxisDistanceType barWidthType) {
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

  set xScrollOffset(double xScrollOffset) {
    _xScrollOffset = xScrollOffset;
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
