part of flutter_custom_charts;

abstract class PlottableXYEntity {
  const PlottableXYEntity({
    required this.primaryAxisMin,
  });

  final double primaryAxisMin;
}

class _PlottableXYEntry {
  const _PlottableXYEntry({
    required this.key,
    required this.values,
  });

  final double key;
  final List<PlottableXYEntity> values;
}

class _XYChartDatasetMap extends ChangeNotifier {
  final List<_PlottableXYEntry> _entries = [];

  int? _firstIndexWithin(Range range) {
    int startIndex = _binarySearch(range.min);

    if (startIndex < _entries.length &&
        _entries[startIndex].key >= range.min &&
        _entries[startIndex].key <= range.max) {
      if (startIndex > 0) {
        // decrementing allows us to have a "scrolling" like effect
        // by painting the first bar outside of the viewport
        startIndex--;
      }

      return startIndex;
    }

    return null;
  }

  int _binarySearch(double key) {
    int low = 0;
    int high = _entries.length - 1;

    while (low <= high) {
      int mid = low + ((high - low) >> 1);
      if (_entries[mid].key < key) {
        low = mid + 1;
      } else if (_entries[mid].key > key) {
        high = mid - 1;
      } else {
        // Adjust to find the first occurrence of the target
        while (mid > 0 && _entries[mid - 1].key == key) {
          mid--;
        }
        return mid;
      }
    }

    // not found
    return low;
  }
}

abstract class BarDataset<T extends StaticBar> extends ChangeNotifier {
  final List<T> _bars = [];
  Range? _secondaryAxisRange;

  List<T> get data => _bars;

  void add(T bar);
  void addAll(List<T> bars, {bool sort = true});
  void insert(int index, T bar);
  void replace(int index, T bar);
  void clear();

  void _computeSecondaryAxisBounds(List<T> bars) {
    if (bars.isEmpty) {
      return;
    }

    _secondaryAxisRange ??= Range(
      min: bars.first.secondaryAxisMin,
      max: bars.first.secondaryAxisMax,
    );

    for (int i = 0; i < bars.length; i++) {
      _secondaryAxisRange!.min =
          min(_secondaryAxisRange!.min, bars[i].secondaryAxisMin);
      _secondaryAxisRange!.max =
          max(_secondaryAxisRange!.max, bars[i].secondaryAxisMax);
    }
  }
}

class StaticBarDataset<T extends StaticBar> extends BarDataset<T> {
  @override
  void add(T bar) {
    _bars.add(bar);
    notifyListeners();
  }

  @override
  void addAll(List<T> bars, {bool sort = true}) {
    _bars.addAll(bars);
    notifyListeners();
  }

  @override
  void insert(int index, T bar) {
    _bars.insert(index, bar);
    notifyListeners();
  }

  @override
  void replace(int index, T bar) {
    _bars[index] = bar;
    notifyListeners();
  }

  @override
  void clear() {
    _bars.clear();
    notifyListeners();
  }
}

class DynamicBarDataset<T extends DynamicBar> extends BarDataset<T> {
  Range? _primaryAxisRange;

  @override
  void add(T bar) {
    if (_bars.isNotEmpty && bar.primaryAxisMin <= _bars.last.primaryAxisMin) {
      throw XYChartException(
          'Cannot add out of order bars on a primary numeric axis. The added bar must have a greater primaryAxisMin than the last bar in the existing dataset.');
    }
    _bars.add(bar);
    _computeDatasetBounds([bar]);
    notifyListeners();
  }

  @override
  void addAll(List<T> bars, {bool sort = true}) {
    if (bars.isEmpty) {
      return;
    }
    if (sort) {
      bars.sort((a, b) => a.primaryAxisMin.compareTo(b.primaryAxisMin));
    }

    if (_bars.isNotEmpty &&
        bars.first.primaryAxisMin <= _bars.last.primaryAxisMin) {
      throw XYChartException(
          'Cannot add out of order bars on a primary numeric axis. The first bar in the added list must have a greater primaryAxisMin than the last bar in the existing dataset.');
    }

    _bars.addAll(bars);
    _computeDatasetBounds(bars);
    notifyListeners();
  }

  @override
  void insert(int index, T bar) {
    if (_bars.isNotEmpty && bar.primaryAxisMin >= _bars[index].primaryAxisMin) {
      throw XYChartException(
          'Cannot add out of order bars on a primary numeric axis. The inserted bar must have an primaryAxisMin smaller than the bar to it\'s right in the existing dataset.');
    }

    if (_bars.length > 1 &&
        bar.primaryAxisMin <= _bars[index - 1].primaryAxisMin) {
      throw XYChartException(
          'Cannot add out of order bars on a primary numeric axis. The inserted bar must have an primaryAxisMin greater than the bar to it\'s left in the existing dataset.');
    }
    _bars.insert(index, bar);
    _computeDatasetBounds([bar]);
    notifyListeners();
  }

  @override
  void replace(int index, T bar) {
    if (_bars.isEmpty) {
      throw XYChartException(
          'Cannot replace a bar in an empty dataset. Add a bar first.');
    }

    if (index < 0 || index > _bars.length - 1) {
      throw XYChartException(
          'Cannot replace a bar at index $index. Index must be between 0 and ${_bars.length - 1}');
    }

    // TODO - verify this logic
    if (index < _bars.length - 1 &&
        bar.primaryAxisMin >= _bars[index + 1].primaryAxisMin) {
      throw XYChartException(
          'Cannot add out of order bars on a primary numeric axis. The inserted bar must have an primaryAxisMin smaller than the bar to it\'s right in the existing dataset.');
    }

    // TODO - verify this logic
    if (index > 0 && bar.primaryAxisMin <= _bars[index - 1].primaryAxisMin) {
      throw XYChartException(
          'Cannot add out of order bars on a primary numeric axis. The inserted bar must have an primaryAxisMin greater than the bar to it\'s left in the existing dataset.');
    }

    final replacedBar = _bars[index];
    _bars[index] = bar;

    if (replacedBar.primaryAxisMax == _primaryAxisRange!.max ||
        replacedBar.primaryAxisMin == _primaryAxisRange!.min) {
      _computePrimaryAxisBounds(_bars);
    }
    if (replacedBar.secondaryAxisMax == _secondaryAxisRange!.max ||
        replacedBar.secondaryAxisMin == _secondaryAxisRange!.min) {
      // TODO
      // What if there are multiple bars with the same secondaryAxisMin or secondaryAxisMax?
      // If that's the case we'd only need to iterate until the same max/min is found.

      // perhaps i need to rethink this approach. perhaps i need two data structures
      // one sorted by primaryAxisMin and one sorted by secondaryAxisMin
      _computeSecondaryAxisBounds(_bars);
    }
    notifyListeners();
  }

  @override
  void clear() {
    _bars.clear();
    notifyListeners();
  }

  void _computePrimaryAxisBounds(List<T> bars) {
    if (bars.isEmpty) {
      return;
    }

    _primaryAxisRange ??= Range(
      min: bars.first.primaryAxisMin,
      max: bars.last.primaryAxisMax,
    );

    _primaryAxisRange!.min =
        min(_primaryAxisRange!.min, bars.first.primaryAxisMin);
    _primaryAxisRange!.max =
        max(_primaryAxisRange!.max, bars.last.primaryAxisMax);
  }

  void _computeDatasetBounds(List<T> bars) {
    _computePrimaryAxisBounds(bars);
    _computeSecondaryAxisBounds(bars);
  }

  int? _firstIndexWithin(Range range) {
    int startIndex = _binarySearch(range.min);

    if (startIndex < _bars.length &&
        _bars[startIndex].primaryAxisMin >= range.min &&
        _bars[startIndex].primaryAxisMin <= range.max) {
      if (startIndex > 0) {
        // decrementing allows us to have a "scrolling" like effect
        // by painting the first bar outside of the viewport
        startIndex--;
      }

      return startIndex;
    }

    return null;
  }

  int _binarySearch(double primaryAxisValue) {
    int low = 0;
    int high = _bars.length - 1;

    while (low <= high) {
      int mid = low + ((high - low) >> 1);
      if (_bars[mid].primaryAxisMin < primaryAxisValue) {
        low = mid + 1;
      } else if (_bars[mid].primaryAxisMin > primaryAxisValue) {
        high = mid - 1;
      } else {
        // Adjust to find the first occurrence of the target
        while (mid > 0 && _bars[mid - 1].primaryAxisMin == primaryAxisValue) {
          mid--;
        }
        return mid;
      }
    }

    // not found
    return low;
  }
}
