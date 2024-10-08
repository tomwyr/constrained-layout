extension MapExtensions<K, V> on Map<K, V> {
  Iterable<(K key, V value)> get records sync* {
    for (var entry in entries) {
      yield (entry.key, entry.value);
    }
  }
}
