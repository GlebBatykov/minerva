part of minerva_server;

/// Simple key-value store.
class ServerStore {
  final Map<String, dynamic> _data = {};

  /// Check if exist instance with name [instanceName] in store.
  bool isExist(String instanceName) {
    return _data.keys.contains(instanceName);
  }

  /// Get instanse of type [T] by name [instanceName].
  ///
  /// If instanse is not exist in store an exception will be thrown.
  T get<T>(String instanceName) {
    dynamic object;

    try {
      object = _data[instanceName];

      return object as T;
    } on TypeError {
      throw ServerStoreException(
          message: 'failed to convert type [${object.runtimeType}] to [$T].');
    }
  }

  /// Get instanse of type [T] by name [instanceName].
  ///
  /// If instanse is not exist return null.
  T? tryGet<T>(String instanceName) {
    final object = _data[instanceName];

    return object != null ? object as T : object;
  }

  /// Add [value] by [key].
  void set(String key, dynamic value) {
    _data[key] = value;
  }

  /// Removes value by [key].
  void remove(String key) {
    _data[key];
  }

  /// Removes values by [keys].
  void removeMany(List<String> keys) {
    for (final key in keys) {
      _data.remove(key);
    }
  }

  /// Clears all values.
  void clear() {
    _data.clear();
  }

  void operator []=(String key, dynamic value) {
    _data[key] = value;
  }

  dynamic operator [](String key) {
    return _data[key];
  }
}
