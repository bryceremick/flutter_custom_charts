part of flutter_custom_charts;

class PointDataset<T extends Point> with _DatasetMutations<T> {
  PointDataset({
    required this.id,
    this.connectPoints = false,
  });

  final _plottableDataset = _PlottableXYDataset<T>();
  final String id;
  bool _isHidden = false;
  final bool connectPoints;

  List<T> get _data => _plottableDataset._data;
  int get length => _plottableDataset._data.length;
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
  void addAll(
    List<T> entities, {
    double? reductionFactor = 1.0,
  }) {
    if (reductionFactor != null) {
      final simplified = simplify(entities, tolerance: reductionFactor);
      _plottableDataset.addAll(simplified);
      __computeDatasetAxisBounds(simplified);
    } else {
      _plottableDataset.addAll(entities);
      __computeDatasetAxisBounds(entities);
    }
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
          'Cannot replace a point at index $index. Index must be between 0 and ${_plottableDataset._data.length - 1}');
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

  List<DatasetEntity<T>> _entitiesWithin(Range range) {
    int lowerBound = __findLowerBound(range.min);
    int upperBound = __findUpperBound(range.max) - 1;

    if (lowerBound <= upperBound && lowerBound != -1 && upperBound != -1) {
      final found = _data.sublist(lowerBound, upperBound + 1);
      if (found.isEmpty) {
        return [];
      }
      return List.generate(
        found.length,
        (index) {
          final i = lowerBound + index;
          return DatasetEntity(
            id: id,
            index: i,
          );
        },
        growable: false,
      );
    }
    return [];
  }

  int __findLowerBound(double min) {
    int start = 0, end = _data.length - 1;
    int result = -1;
    while (start <= end) {
      int mid = (start + end) >> 1;
      if (_data[mid].primaryAxisValue >= min) {
        result = mid;
        end = mid - 1;
      } else {
        start = mid + 1;
      }
    }
    return result;
  }

  int __findUpperBound(double max) {
    int start = 0, end = _data.length - 1;
    int result = -1;
    while (start <= end) {
      int mid = (start + end) >> 1;
      if (_data[mid].primaryAxisValue > max) {
        result = mid;
        end = mid - 1;
      } else {
        start = mid + 1;
      }
    }
    return result == -1 ? _data.length : result;
  }

  void __computeDatasetAxisBounds(List<T> points) {
    __computePrimaryAxisBounds(points);
    __computeSecondaryAxisBounds(points);
  }

  void __computePrimaryAxisBounds(List<T> points) {
    if (points.isEmpty) {
      return;
    }

    _plottableDataset._primaryAxisRange ??= Range(
      min: points.first.primaryAxisValue,
      max: points.last.primaryAxisValue,
    );

    _plottableDataset._primaryAxisRange!.min = math.min(
        _plottableDataset._primaryAxisRange!.min,
        points.first.primaryAxisValue);
    _plottableDataset._primaryAxisRange!.max = math.max(
        _plottableDataset._primaryAxisRange!.max, points.last.primaryAxisValue);
  }

  void __computeSecondaryAxisBounds(List<T> bars) {
    if (bars.isEmpty) {
      return;
    }

    _plottableDataset._secondaryAxisRange ??= Range(
      min: bars.first.secondaryAxisValue,
      max: bars.first.secondaryAxisValue,
    );

    for (int i = 0; i < bars.length; i++) {
      _plottableDataset._secondaryAxisRange!.min = math.min(
          _plottableDataset._secondaryAxisRange!.min,
          bars[i].secondaryAxisValue);
      _plottableDataset._secondaryAxisRange!.max = math.max(
          _plottableDataset._secondaryAxisRange!.max,
          bars[i].secondaryAxisValue);
    }
  }
}
