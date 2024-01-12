part of flutter_custom_charts;

class NewXYChart extends StatelessWidget {
  const NewXYChart({
    super.key,
    required this.primaryAxisController,
    this.padding = EdgeInsets.zero,
    this.fill = Colors.black87,
  });

  // {
  //   bool isPositive = true;
  //   Timer.periodic(const Duration(milliseconds: 100), (timer) {
  //     if (timer.tick % 30 == 0) {
  //       isPositive = !isPositive;
  //     }
  //     final offset = primaryAxisController.axisScrollOffset - 1;
  //     primaryAxisController._setAxisScrollOffset(offset, padding);
  //     print(primaryAxisController.axisScrollOffset);
  //   });
  // }
  final PrimaryAxisController primaryAxisController;
  final EdgeInsets padding;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: GestureDetector(
        child: ClipRect(
          child: CustomPaint(
            painter: ChartCanvas(
              primaryAxisController: primaryAxisController
                .._setAxisScrollOffset(
                    primaryAxisController.axisScrollOffset, padding),
              padding: padding,
              fill: fill,
            ),
          ),
        ),
      ),
    );
  }
}
