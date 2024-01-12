part of flutter_custom_charts;

abstract class _AxisController extends ChangeNotifier {
  _AxisController({
    required this.position,
    Range? explicitRange,
  }) {
    _explicitRange = explicitRange;
  }

  final AxisPosition position;
  Range? _explicitRange;

  Range? get explicitRange => _explicitRange;
  AxisDirection get direction =>
      position == AxisPosition.left || position == AxisPosition.right
          ? AxisDirection.vertical
          : AxisDirection.horizontal;

  set explicitRange(Range? range) {
    if (range != _explicitRange) {
      _explicitRange = range;
      notifyListeners();
    }
  }
}

abstract class PrimaryAxisController extends _AxisController
    with ConstrainedPainter
    implements TickerProvider {
  PrimaryAxisController({
    required super.position,
    super.explicitRange,
  });

  ChartAnimation? _zoomAnimation;
  double _scrollOffset = 0;
  double get axisScrollOffset => _scrollOffset;
  void _setAxisScrollOffset(double offset, EdgeInsets chartPadding) {
    switch (position) {
      case AxisPosition.left:
        _scrollOffset = offset + chartPadding.left;
        break;
      case AxisPosition.right:
        _scrollOffset = offset + chartPadding.right;
        break;
      case AxisPosition.top:
        _scrollOffset = offset + chartPadding.top;
        break;
      case AxisPosition.bottom:
        _scrollOffset = offset + chartPadding.left;
        break;
    }
    notifyListeners();
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }
}

abstract class SecondaryAxisController extends _AxisController {
  SecondaryAxisController({
    required super.position,
    super.explicitRange,
  });
}
