part of flutter_custom_charts;

class AnimationDetails {
  const AnimationDetails({
    required this.duration,
    this.curve = Curves.linear,
  });
  final Duration duration;
  final Curve curve;
}
