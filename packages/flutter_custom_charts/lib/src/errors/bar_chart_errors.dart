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

class OutOfOrderException implements XYChartException {
  @override
  final String message;

  OutOfOrderException(this.message);

  OutOfOrderException.fromCompareToLeft(double added, double left)
      : message =
            'Cannot add entities out of order on the primary axis. The first new entry added must have a primaryAxisMin[$added] >= than the left entity in the existing dataset[$left]';

  OutOfOrderException.fromCompareToRight(double added, double right)
      : message =
            'Cannot add entities out of order on the primary axis. The first new entry added must have a primaryAxisMin[$added] <= than the right entity in the existing dataset[$right]';

  @override
  String toString() {
    return 'OutOfOrderException: $message';
  }
}
