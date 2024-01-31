part of flutter_custom_charts;

abstract mixin class _DatasetMutations<T extends PlottableXYEntity> {
  void add(T entity);
  void addAll(List<T> entities);
  void insert(int index, T entity);
  void replace(int index, T entity);
  void clear();
  int? _firstIndexWithin(Range range);
}

class _XYChartDataset<T extends PlottableXYEntity> extends ChangeNotifier
    with _DatasetMutations<T> {
  final List<T> _data = [];
  Range? _primaryAxisRange;
  Range? _secondaryAxisRange;

  @override
  void add(T entity) {
    // compare to left
    if (_data.isNotEmpty && entity.primaryAxisMin < _data.last.primaryAxisMin) {
      throw OutOfOrderException.fromCompareToLeft(
          entity.primaryAxisMin, _data.last.primaryAxisMin);
    }
    _data.add(entity);
  }

  @override
  void addAll(List<T> entities) {
    if (entities.isEmpty) {
      return;
    }
    entities.sort((a, b) => a.primaryAxisMin.compareTo(b.primaryAxisMin));

    // compare to left
    if (_data.isNotEmpty &&
        entities.first.primaryAxisMin < _data.last.primaryAxisMin) {
      throw OutOfOrderException.fromCompareToLeft(
          entities.first.primaryAxisMin, _data.last.primaryAxisMin);
    }

    _data.addAll(entities);
  }

  @override
  void insert(int index, T entity) {
    // compare to right
    if (_data.isNotEmpty &&
        entity.primaryAxisMin > _data[index].primaryAxisMin) {
      throw OutOfOrderException.fromCompareToRight(
          entity.primaryAxisMin, _data[index].primaryAxisMin);
    }

    // compare to left
    if (_data.length > 1 &&
        entity.primaryAxisMin < _data[index - 1].primaryAxisMin) {
      throw OutOfOrderException.fromCompareToLeft(
          entity.primaryAxisMin, _data[index - 1].primaryAxisMin);
    }
    _data.insert(index, entity);
  }

  @override
  void replace(int index, T entity) {
    if (_data.isEmpty) {
      throw XYChartException(
          'Cannot replace a bar in an empty dataset. Add a bar first.');
    }

    if (index < 0 || index > _data.length - 1) {
      throw XYChartException(
          'Cannot replace a bar at index $index. Index must be between 0 and ${_data.length - 1}');
    }

    // TODO - verify this logic
    if (index < _data.length - 1 &&
        entity.primaryAxisMin > _data[index + 1].primaryAxisMin) {
      throw OutOfOrderException.fromCompareToRight(
          entity.primaryAxisMin, _data[index + 1].primaryAxisMin);
    }

    // TODO - verify this logic
    if (index > 0 && entity.primaryAxisMin < _data[index - 1].primaryAxisMin) {
      throw OutOfOrderException.fromCompareToLeft(
          entity.primaryAxisMin, _data[index - 1].primaryAxisMin);
    }

    _data[index] = entity;
  }

  @override
  void clear() {
    _data.clear();
    _primaryAxisRange = null;
    _secondaryAxisRange = null;
    _notifyListeners();
  }

  void _notifyListeners() {
    notifyListeners();
  }

  /// Returns [null] if not found.
  @override
  int? _firstIndexWithin(Range range) {
    int startIndex = __binarySearch(range.min);

    if (startIndex < _data.length &&
        _data[startIndex].primaryAxisMin >= range.min &&
        _data[startIndex].primaryAxisMin <= range.max) {
      if (startIndex > 0) {
        // decrementing allows us to have a "scrolling" like effect
        // by painting the first bar outside of the viewport
        startIndex--;
      }

      return startIndex;
    }

    return null;
  }

  int __binarySearch(double value) {
    int low = 0;
    int high = _data.length - 1;

    while (low <= high) {
      int mid = low + ((high - low) >> 1);
      if (_data[mid].primaryAxisMin < value) {
        low = mid + 1;
      } else if (_data[mid].primaryAxisMin > value) {
        high = mid - 1;
      } else {
        // Adjust to find the first occurrence of the target
        while (mid > 0 && _data[mid - 1].primaryAxisMin == value) {
          mid--;
        }
        return mid;
      }
    }

    // not found
    return low;
  }
}

class BarDataset<T extends Bar> with _DatasetMutations<T> {
  final _plottableDataset = _XYChartDataset<T>();

  List<T> get _data => _plottableDataset._data;
  Range? get primaryAxisRange => _plottableDataset._primaryAxisRange;
  Range? get secondaryAxisRange => _plottableDataset._secondaryAxisRange;

  @override
  void add(T entity) {
    _plottableDataset.add(entity);
    __computeDatasetAxisBounds([entity]);
    _plottableDataset._notifyListeners();
  }

  @override
  void addAll(List<T> entities) {
    _plottableDataset.addAll(entities);
    __computeDatasetAxisBounds(entities);
    _plottableDataset._notifyListeners();
  }

  @override
  void insert(int index, T entity) {
    _plottableDataset.insert(index, entity);
    __computeDatasetAxisBounds([entity]);
    _plottableDataset._notifyListeners();
  }

  @override
  void replace(int index, T entity) {
    late final T barToReplace;
    try {
      barToReplace = _plottableDataset._data[index] as T;
    } catch (e) {
      throw XYChartException(
          'Cannot replace a bar at index $index. Index must be between 0 and ${_plottableDataset._data.length - 1}');
    }
    _plottableDataset.replace(index, entity);

    if (barToReplace.primaryAxisMax ==
            _plottableDataset._primaryAxisRange!.max ||
        barToReplace.primaryAxisMin ==
            _plottableDataset._primaryAxisRange!.min) {
      __computePrimaryAxisBounds(_plottableDataset._data as List<T>);
    }
    if (barToReplace.secondaryAxisMax ==
            _plottableDataset._secondaryAxisRange!.max ||
        barToReplace.secondaryAxisMin ==
            _plottableDataset._secondaryAxisRange!.min) {
      // TODO
      // What if there are multiple bars with the same secondaryAxisMin or secondaryAxisMax?
      // If that's the case we'd only need to iterate until the same max/min is found.

      // perhaps i need to rethink this approach. perhaps i need two data structures
      // one sorted by primaryAxisMin and one sorted by secondaryAxisMin
      __computeSecondaryAxisBounds(_plottableDataset._data as List<T>);
    }
    _plottableDataset._notifyListeners();
  }

  @override
  void clear() => _plottableDataset.clear();

  @override
  int? _firstIndexWithin(Range range) =>
      _plottableDataset._firstIndexWithin(range);

  void __computeDatasetAxisBounds(List<T> bars) {
    __computePrimaryAxisBounds(bars);
    __computeSecondaryAxisBounds(bars);
  }

  void __computePrimaryAxisBounds(List<T> bars) {
    if (bars.isEmpty) {
      return;
    }

    _plottableDataset._primaryAxisRange ??= Range(
      min: bars.first.primaryAxisMin,
      max: bars.last.primaryAxisMax,
    );

    _plottableDataset._primaryAxisRange!.min = min(
        _plottableDataset._primaryAxisRange!.min, bars.first.primaryAxisMin);
    _plottableDataset._primaryAxisRange!.max =
        max(_plottableDataset._primaryAxisRange!.max, bars.last.primaryAxisMax);
  }

  void __computeSecondaryAxisBounds(List<T> bars) {
    if (bars.isEmpty) {
      return;
    }

    _plottableDataset._secondaryAxisRange ??= Range(
      min: bars.first.secondaryAxisMin,
      max: bars.first.secondaryAxisMax,
    );

    for (int i = 0; i < bars.length; i++) {
      _plottableDataset._secondaryAxisRange!.min = min(
          _plottableDataset._secondaryAxisRange!.min, bars[i].secondaryAxisMin);
      _plottableDataset._secondaryAxisRange!.max = max(
          _plottableDataset._secondaryAxisRange!.max, bars[i].secondaryAxisMax);
    }
  }
}
