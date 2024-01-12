part of flutter_custom_charts;

// TODO - change primaryAxisMax and primaryAxisMin to a Range instance

class DynamicBar extends StaticBar {
  DynamicBar({
    required this.primaryAxisMin,
    required this.primaryAxisMax,
    required super.secondaryAxisMax,
    super.secondaryAxisMin,
    super.fill,
    super.stroke,
    super.label,
    super.lines,
  }) {
    if (primaryAxisMin >= primaryAxisMax) {
      throw XYChartException('Bar xMin must be less than xMax');
    }
  }

  final double primaryAxisMax;
  final double primaryAxisMin;

  double get perceivedWidth => (primaryAxisMax - primaryAxisMin).abs();
}
