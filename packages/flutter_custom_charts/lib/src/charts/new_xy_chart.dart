part of flutter_custom_charts;

class NewXYChart extends StatelessWidget {
  const NewXYChart({
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
          if (primaryAxisController._implicitDataRange != null) {
            primaryAxisController._onDragUpdate(
              details,
              implicitDatasetRange: primaryAxisController._implicitDataRange!,
            );
          }
        },
        onVerticalDragUpdate: (details) {
          if (primaryAxisController._implicitDataRange != null) {
            primaryAxisController._onDragUpdate(
              details,
              implicitDatasetRange: primaryAxisController._implicitDataRange!,
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
