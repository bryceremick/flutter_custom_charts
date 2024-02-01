part of flutter_custom_charts;

class Range {
  Range({required this.min, required this.max});
  double min;
  double max;

  Range inverted() {
    return Range(min: max, max: min);
  }

  bool isWithin(Range range) {
    return min >= range.min && max <= range.max;
  }

  double difference() {
    return (max - min).abs();
  }

  double midpoint() {
    return (min + max) / 2;
  }

  List<double> generateSteps(int numSteps) {
    return List.generate(
        numSteps, (i) => min + (max - min) / (numSteps - 1) * i);
  }

  @override
  String toString() {
    return 'Range(min: $min, max: $max)';
  }
}
