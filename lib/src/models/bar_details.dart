part of flutter_custom_charts;

class ChartIcon {
  ChartIcon({
    required this.icon,
    required this.size,
    required this.color,
  });

  final IconData icon;
  final double size;
  final Color color;
}

// TODO - use this class for all labels/text throughout the library
class ChartText {
  ChartText({
    required this.text,
    required this.style,
  });

  final String text;
  final TextStyle style;
}

class BarDetails {
  BarDetails({
    this.icon,
    this.text,
  });

  final ChartText? text;
  final ChartIcon? icon;
}

class BarDetailsSpacing {
  const BarDetailsSpacing({
    this.spaceAbove,
    this.spaceBelow,
  });
  final double? spaceAbove;
  final double? spaceBelow;
}
