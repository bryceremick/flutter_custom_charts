part of flutter_custom_charts;

class ChartAnimation {
  ChartAnimation({
    required this.curve,
    required void Function(double value) onUpdate,
    required AnimationController controller,
  }) {
    _onUpdate = onUpdate;
    _controller = controller;
    _tween = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: curve,
      ),
    )..addListener(() => _onUpdate(value));
  }

  final Curve curve;
  late final AnimationController _controller;
  late final Animation<double> _tween;
  late void Function(double value) _onUpdate;
  double get value => _tween.value;
  bool get isAnimating => _controller.isAnimating;

  set onUpdate(void Function(double value) onUpdate) {
    _onUpdate = onUpdate;
  }

  void start({bool isForward = true}) {
    _controller.reset();
    if (isForward) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void stop() {
    _controller.stop();
  }
}
