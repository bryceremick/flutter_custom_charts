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
    final constraints = ConstrainedArea(
      xMin: 0,
      xMax: size.width,
      yMin: 0,
      yMax: size.height,
    );

    // canvas background
    paintRectangle(canvas, constraints: constraints, fill: fill);

    // chart
    primaryAxisController.paint(
      canvas,
      constraints: constraints.shrink(padding),
    );

    // chart padding - should i remove this?
    _paintPadding(canvas, constraints, padding, Colors.green);
  }

  void _paintPadding(
    Canvas canvas,
    ConstrainedArea constraints,
    EdgeInsets padding,
    Color fill,
  ) {
    // left
    paintRectangle(
      canvas,
      constraints: constraints.copyWith(
        xMax: constraints.xMin + padding.left,
      ),
      fill: fill,
    );

    // top
    paintRectangle(
      canvas,
      constraints: constraints.copyWith(
        yMax: constraints.yMin + padding.top,
      ),
      fill: fill,
    );

    // right
    paintRectangle(
      canvas,
      constraints: constraints.copyWith(
        xMin: constraints.xMax - padding.right,
      ),
      fill: fill,
    );

    // bottom
    paintRectangle(
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
