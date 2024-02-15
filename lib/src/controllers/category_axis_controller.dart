part of flutter_custom_charts;

class PrimaryCategoryAxisController<T extends Bar, K extends Point>
    extends PrimaryAxisController {
  PrimaryCategoryAxisController({
    required this.secondaryAxisControllers,
    super.position = AxisPosition.bottom,
    super.isScrollable = true,
    super.scrollableRange,
    super.explicitRange,
    super.barDetailsSpacing,
  }) {
    for (final secondary in secondaryAxisControllers) {
      verifyAxisPositions(position, secondary.position);
      secondary.addListener(notifyListeners);
    }
  }

  // add an axis max value. If set, the axis will not scroll
  // changing this value is the only time i need to loop through bars
  // to set the primary axis constraints (xMin, xMax)
  //
  // if axis is scrollable, need to know the pixel per unit ratio

  final List<SecondaryNumericAxisController<T, K>> secondaryAxisControllers;

  @override
  void _onTapDown(TapDownDetails details) {
    //
  }

  @override
  void paint(
    Canvas canvas, {
    required ConstrainedArea constraints,
  }) {
    //
  }

  @override
  void dispose() {
    super.dispose();
    for (final secondary in secondaryAxisControllers) {
      secondary.dispose();
    }
  }
}
