part of flutter_custom_charts;

class PointDataset<T extends Point> with _DatasetMutations<T> {
  final _plottableDataset = _PlottableXYDataset<T>();

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

  @override
  int? _firstIndexWithin(Range range) =>
      _plottableDataset._firstIndexWithin(range);

  void __computeDatasetAxisBounds(List<T> points) {
    __computePrimaryAxisBounds(points);
    __computeSecondaryAxisBounds(points);
  }

  void __computePrimaryAxisBounds(List<T> points) {
    if (points.isEmpty) {
      return;
    }

    _plottableDataset._primaryAxisRange ??= Range(
      min: points.first.point.dx,
      max: points.last.point.dx,
    );

    _plottableDataset._primaryAxisRange!.min =
        min(_plottableDataset._primaryAxisRange!.min, points.first.point.dx);
    _plottableDataset._primaryAxisRange!.max =
        max(_plottableDataset._primaryAxisRange!.max, points.last.point.dx);
  }

  void __computeSecondaryAxisBounds(List<T> bars) {
    if (bars.isEmpty) {
      return;
    }

    _plottableDataset._secondaryAxisRange ??= Range(
      min: bars.first.point.dy,
      max: bars.first.point.dy,
    );

    for (int i = 0; i < bars.length; i++) {
      _plottableDataset._secondaryAxisRange!.min =
          min(_plottableDataset._secondaryAxisRange!.min, bars[i].point.dy);
      _plottableDataset._secondaryAxisRange!.max =
          max(_plottableDataset._secondaryAxisRange!.max, bars[i].point.dy);
    }
  }
}
