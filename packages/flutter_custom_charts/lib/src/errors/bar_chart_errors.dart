part of flutter_custom_charts;

class BarChartException implements Exception {
  final String message;

  BarChartException(this.message);

  @override
  String toString() {
    return 'BarChartException: $message';
  }
}

class OutOfBoundsException implements BarChartException {
  @override
  final String message;

  OutOfBoundsException(this.message);

  @override
  String toString() {
    return 'OutOfBoundsException: $message';
  }
}
