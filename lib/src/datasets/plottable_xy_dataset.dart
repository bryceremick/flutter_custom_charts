part of flutter_custom_charts;

abstract mixin class _DatasetMutations<T extends PlottableXYEntity> {
  T? get(int index);
  void add(T entity);
  void addAll(List<T> entities);
  void insert(int index, T entity);
  void replace(int index, T entity);
  void clear();
  int? _firstIndexWithin(Range range);
}

class _PlottableXYDataset<T extends PlottableXYEntity> extends ChangeNotifier
    with _DatasetMutations<T> {
  final List<T> _data = [];
  Range? _primaryAxisRange;
  Range? _secondaryAxisRange;

  @override
  T? get(int index) {
    if (index < 0 || index > _data.length - 1) {
      return null;
    }
    return _data[index];
  }

  @override
  void add(T entity) {
    // compare to left
    if (_data.isNotEmpty && entity.sortableValue < _data.last.sortableValue) {
      throw OutOfOrderException.fromCompareToLeft(
          entity.sortableValue, _data.last.sortableValue);
    }
    _data.add(entity);
  }

  @override
  void addAll(List<T> entities) {
    if (entities.isEmpty) {
      return;
    }
    entities.sort((a, b) => a.sortableValue.compareTo(b.sortableValue));

    // compare to left
    if (_data.isNotEmpty &&
        entities.first.sortableValue < _data.last.sortableValue) {
      throw OutOfOrderException.fromCompareToLeft(
          entities.first.sortableValue, _data.last.sortableValue);
    }

    _data.addAll(entities);
  }

  @override
  void insert(int index, T entity) {
    // compare to right
    if (_data.isNotEmpty && entity.sortableValue > _data[index].sortableValue) {
      throw OutOfOrderException.fromCompareToRight(
          entity.sortableValue, _data[index].sortableValue);
    }

    // compare to left
    if (_data.length > 1 &&
        entity.sortableValue < _data[index - 1].sortableValue) {
      throw OutOfOrderException.fromCompareToLeft(
          entity.sortableValue, _data[index - 1].sortableValue);
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
        entity.sortableValue > _data[index + 1].sortableValue) {
      throw OutOfOrderException.fromCompareToRight(
          entity.sortableValue, _data[index + 1].sortableValue);
    }

    // TODO - verify this logic
    if (index > 0 && entity.sortableValue < _data[index - 1].sortableValue) {
      throw OutOfOrderException.fromCompareToLeft(
          entity.sortableValue, _data[index - 1].sortableValue);
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
    // print(range);
    // print('startIndex: $startIndex');
    // print('min: ${_data[startIndex].sortableValue}');

    if (startIndex < _data.length &&
        _data[startIndex].sortableValue >= range.min &&
        _data[startIndex].sortableValue <= range.max) {
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
      if (_data[mid].sortableValue < value) {
        low = mid + 1;
      } else if (_data[mid].sortableValue > value) {
        high = mid - 1;
      } else {
        // Adjust to find the first occurrence of the target
        while (mid > 0 && _data[mid - 1].sortableValue == value) {
          mid--;
        }
        return mid;
      }
    }

    // not found
    return low;
  }
}
