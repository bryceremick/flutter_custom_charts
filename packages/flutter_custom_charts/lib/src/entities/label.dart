part of flutter_custom_charts;

class Label extends LabelPainter {
  Label({
    required this.text,
    this.style = const TextStyle(fontSize: 12, color: Colors.white),
    this.alignment = Alignment.center,
    this.padding = const EdgeInsets.all(0),
  });

  final String text;
  final TextStyle style;
  final Alignment alignment;
  final EdgeInsets padding;

  @override
  void paint(
    Canvas canvas, {
    required ConstrainedArea area,
  }) {
    super.constraints = area.shrink(padding);
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: style,
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: constraints.width);

    // default alignment is top left
    double x = constraints.xMin;
    double y = constraints.yMin;

    if (alignment.x == 0) {
      // horizontal center alignment
      x += (constraints.xMax - constraints.xMin - textPainter.width) / 2;
    } else if (alignment.x == 1) {
      // horizontal right alignment
      x = constraints.xMax - textPainter.width;
    }

    if (alignment.y == 0) {
      // vertical center alignment
      y += (constraints.yMax - constraints.yMin - textPainter.height) / 2;
    } else if (alignment.y == 1) {
      // vertical bottom alignment
      y = constraints.yMax - textPainter.height;
    }
    print('x: $x, y: $y');
    textPainter.paint(canvas, Offset(x, y));
  }
}
