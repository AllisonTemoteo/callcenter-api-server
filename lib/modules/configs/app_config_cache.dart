class AppConfigCache {
  final Map<String, dynamic> _cache = {};

  T? get<T>(String key) {
    return _cache[key];
  }

  void set<T>(String key, T value) {
    _cache[key] = value;
  }

  void remove(String key) {
    _cache.remove(key);
  }

  void clear() {
    _cache.clear();
  }
}
