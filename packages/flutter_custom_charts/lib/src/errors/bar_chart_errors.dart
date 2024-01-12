part of flutter_custom_charts;

class XYChartException implements Exception {
  final String message;

  XYChartException(this.message);

  @override
  String toString() {
    return 'XYChartException: $message';
  }
}

class OutOfBoundsException implements XYChartException {
  @override
  final String message;

  OutOfBoundsException(this.message);

  @override
  String toString() {
    return 'OutOfBoundsException: $message';
  }
}
