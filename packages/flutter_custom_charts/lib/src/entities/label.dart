part of flutter_custom_charts;

class Label extends ConstrainedPainter {
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
    required ConstrainedArea constraints,
  }) {
    super.constraints = constraints.shrink(padding);
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: style,
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: super.constraints.width);

    // default alignment is top left
    double x = super.constraints.xMin;
    double y = super.constraints.yMin;

    if (alignment.x == 0) {
      // horizontal center alignment
      x += (super.constraints.xMax -
              super.constraints.xMin -
              textPainter.width) /
          2;
    } else if (alignment.x == 1) {
      // horizontal right alignment
      x = super.constraints.xMax - textPainter.width;
    }

    if (alignment.y == 0) {
      // vertical center alignment
      y += (super.constraints.yMax -
              super.constraints.yMin -
              textPainter.height) /
          2;
    } else if (alignment.y == 1) {
      // vertical bottom alignment
      y = super.constraints.yMax - textPainter.height;
    }

    textPainter.paint(canvas, Offset(x, y));
  }
}
