part of flutter_custom_charts;

class DatasetEntity<T> {
  DatasetEntity({
    required this.id,
    required this.index,
  });

  final String id;
  final int index;

  @override
  String toString() {
    return 'DatasetEntity{id: $id, index: $index}';
  }
}
