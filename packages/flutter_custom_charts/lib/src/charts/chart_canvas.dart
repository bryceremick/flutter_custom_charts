part of flutter_custom_charts;

class ChartCanvas extends CustomPainter {
  ChartCanvas({
    required this.primaryAxisController,
    required this.padding,
    required this.fill,
  }) : super(repaint: primaryAxisController);
  final PrimaryAxisController primaryAxisController;
  final EdgeInsets padding;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    // debugPrint('PAINTING');
    final constraints = ConstrainedArea(
      xMin: 0,
      xMax: size.width,
      yMin: 0,
      yMax: size.height,
    );
    _paintRectangle(canvas, constraints: constraints, fill: fill);
    _paintPadding(canvas, constraints, padding, Colors.red);
    primaryAxisController.paint(
      canvas,
      constraints: constraints.shrink(padding),
    );
  }

  void _paintRectangle(
    Canvas canvas, {
    required ConstrainedArea constraints,
    required Color fill,
  }) {
    final background = Rect.fromLTRB(
      constraints.xMin,
      constraints.yMin,
      constraints.xMax,
      constraints.yMax,
    );
    canvas.drawRect(
      background,
      Paint()
        ..color = fill
        ..style = PaintingStyle.fill,
    );
  }

  void _paintPadding(
    Canvas canvas,
    ConstrainedArea constraints,
    EdgeInsets padding,
    Color fill,
  ) {
    // left
    _paintRectangle(
      canvas,
      constraints: constraints.copyWith(
        xMax: constraints.xMin + padding.left,
      ),
      fill: fill,
    );

    // top
    _paintRectangle(
      canvas,
      constraints: constraints.copyWith(
        yMax: constraints.yMin + padding.top,
      ),
      fill: fill,
    );

    // right
    _paintRectangle(
      canvas,
      constraints: constraints.copyWith(
        xMin: constraints.xMax - padding.right,
      ),
      fill: fill,
    );

    // bottom
    _paintRectangle(
      canvas,
      constraints: constraints.copyWith(
        yMin: constraints.yMax - padding.bottom,
      ),
      fill: fill,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
