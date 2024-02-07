part of flutter_custom_charts;

class AxisDetails {
  const AxisDetails({
    required this.stepLabelFormatter,
    this.steps = 6,
    this.crossAlignmentPixelSize = 32,
    this.name,
    this.nameLabelStyle = const TextStyle(fontSize: 12, color: Colors.white),
    this.stepLabelStyle = const TextStyle(fontSize: 12, color: Colors.white),
    this.gridStyle = const AxisGridStyle(
      color: Colors.grey,
      strokeWidth: 1,
    ),
  });

  final String? name;
  final TextStyle nameLabelStyle;
  final TextStyle stepLabelStyle;
  final String Function(double value) stepLabelFormatter;
  final double crossAlignmentPixelSize;
  final int steps;
  final AxisGridStyle? gridStyle;
}

class AxisGridStyle {
  const AxisGridStyle({
    required this.color,
    required this.strokeWidth,
  });

  final Color color;
  final double strokeWidth;
}
