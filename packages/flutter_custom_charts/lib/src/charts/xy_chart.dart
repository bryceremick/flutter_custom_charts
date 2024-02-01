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
        onHorizontalDragUpdate: (details) {
          if (primaryAxisController._implicitPrimaryAxisDataRange != null) {
            primaryAxisController._onDragUpdate(
              details,
              implicitDatasetRange:
                  primaryAxisController._implicitPrimaryAxisDataRange!,
            );
          }
        },
        onVerticalDragUpdate: (details) {
          if (primaryAxisController._implicitPrimaryAxisDataRange != null) {
            primaryAxisController._onDragUpdate(
              details,
              implicitDatasetRange:
                  primaryAxisController._implicitPrimaryAxisDataRange!,
            );
          }
        },
        child: ClipRect(
          child: CustomPaint(
            painter: ChartCanvas(
              primaryAxisController: primaryAxisController,
              padding: padding,
              fill: fill,
            ),
          ),
        ),
      ),
    );
  }
}
