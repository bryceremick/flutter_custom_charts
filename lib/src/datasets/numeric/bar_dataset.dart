part of flutter_custom_charts;

class BarDataset<T extends Bar> with _DatasetMutations<T> {
  BarDataset({
    required this.id,
  });

  final _plottableDataset = _PlottableXYDataset<T>();
  final String id;
  bool _isHidden = false;

  List<T> get _data => _plottableDataset._data;
  Range? get primaryAxisRange => _plottableDataset._primaryAxisRange;
  Range? get secondaryAxisRange => _plottableDataset._secondaryAxisRange;
  bool get isHidden => _isHidden;

  @override
  T? get(int index) => _plottableDataset.get(index);

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
    late final T entityToReplace;
    try {
      entityToReplace = _plottableDataset._data[index];
    } catch (e) {
      throw XYChartException(
          'Cannot replace a bar at index $index. Index must be between 0 and ${_plottableDataset._data.length - 1}');
    }

    if (entity != entityToReplace) {
      throw InvalidEntityReplacement();
    }

    _plottableDataset.replace(index, entity);
    _plottableDataset._notifyListeners();
  }

  @override
  void clear() => _plottableDataset.clear();

  void hide() {
    if (_isHidden) {
      return;
    }
    _isHidden = true;
    _plottableDataset._notifyListeners();
  }

  void show() {
    if (!_isHidden) {
      return;
    }
    _isHidden = false;
    _plottableDataset._notifyListeners();
  }

  @override
  int? _firstIndexWithin(Range range) =>
      _plottableDataset._firstIndexWithin(range);

  List<DatasetEntity<T>> _entitiesContaining(Offset position) {
    int start = 0;
    int end = _data.length - 1;
    int foundIndex = -1;
    List<DatasetEntity<T>> result = [];

    // Binary search to find the closest index with primaryAxisMin <= position.dx
    while (start <= end) {
      int mid = start + (end - start) ~/ 2;
      if (_data[mid].primaryAxisMin <= position.dx) {
        foundIndex = mid;
        start = mid + 1;
      } else {
        end = mid - 1;
      }
    }
    if (foundIndex == -1) {
      return result;
    }

    // iterate left of found index to find overlapped bars
    for (int i = foundIndex;
        i >= 0 && _data[i].primaryAxisMax >= position.dx;
        i--) {
      if (_data[i].primaryAxisMin <= position.dx &&
          _data[i].secondaryAxisMin <= position.dy &&
          _data[i].secondaryAxisMax >= position.dy) {
        result.add(DatasetEntity(id: id, index: i));
      }
    }

    // iterate right of found index to find overlapped bars
    for (int i = foundIndex + 1;
        i < _data.length && _data[i].primaryAxisMin <= position.dx;
        i++) {
      if (_data[i].primaryAxisMax >= position.dx &&
          _data[i].secondaryAxisMin <= position.dy &&
          _data[i].secondaryAxisMax >= position.dy) {
        result.add(DatasetEntity(id: id, index: i));
      }
    }

    return result;
  }

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

    _plottableDataset._primaryAxisRange!.min = math.min(
        _plottableDataset._primaryAxisRange!.min, bars.first.primaryAxisMin);
    _plottableDataset._primaryAxisRange!.max = math.max(
        _plottableDataset._primaryAxisRange!.max, bars.last.primaryAxisMax);
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
      _plottableDataset._secondaryAxisRange!.min = math.min(
          _plottableDataset._secondaryAxisRange!.min, bars[i].secondaryAxisMin);
      _plottableDataset._secondaryAxisRange!.max = math.max(
          _plottableDataset._secondaryAxisRange!.max, bars[i].secondaryAxisMax);
    }
  }
}
