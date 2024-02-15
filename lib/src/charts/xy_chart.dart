part of flutter_custom_charts;

class XYChart extends StatelessWidget {
  const XYChart({
    super.key,
    required this.primaryAxisController,
    this.padding = EdgeInsets.zero,
    this.fill = Colors.transparent,
  });
  final PrimaryAxisController primaryAxisController;
  final EdgeInsets padding;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: GestureDetector(
        onTapDown: (details) => primaryAxisController._onTapDown(details),
        onHorizontalDragUpdate: (details) {
          // TODO - this is not necessary, do this check in the controller
          if (primaryAxisController._implicitPrimaryAxisDataRange != null) {
            primaryAxisController._onDragUpdate(
              details,
              implicitDatasetRange:
                  primaryAxisController._implicitPrimaryAxisDataRange!,
            );
          }
        },
        onVerticalDragUpdate: (details) {
          // TODO - this is not necessary, do this check in the controller
          if (primaryAxisController._implicitPrimaryAxisDataRange != null) {
            primaryAxisController._onDragUpdate(
              details,
              implicitDatasetRange:
                  primaryAxisController._implicitPrimaryAxisDataRange!,
            );
          }
        },
        child: ClipRect(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: ChartCanvas(
                primaryAxisController: primaryAxisController,
                padding: padding,
                fill: fill,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
