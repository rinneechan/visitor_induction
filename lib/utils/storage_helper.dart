class DummyBox {
  final Map<String, dynamic> _storage = {};

  dynamic get(String key) => _storage[key];
  void put(String key, dynamic value) => _storage[key] = value;
}

class StorageHelper {
  static final DummyBox box = DummyBox();

  static dynamic read(String key) => box.get(key);
  static void write(String key, dynamic value) => box.put(key, value);
}
