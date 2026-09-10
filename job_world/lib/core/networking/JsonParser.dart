class JsonParser {
  // Converts a dynamic value to the required type (e.g., String, int, bool)
  static T asT<T>(dynamic value, [T? defaultValue]) {
    if (value == null) return defaultValue ?? _defaultValueForType<T>();
    try {
      if (value is T) return value;
      if (T == String) return value.toString() as T;
      if (T == int) return int.tryParse(value.toString()) as T;
      if (T == double) return double.tryParse(value.toString()) as T;
      if (T == bool) return (value.toString().toLowerCase() == 'true') as T;
      if (T == DateTime) return DateTime.tryParse(value.toString()) as T;
    } catch (_) {}
    throw Exception("Type cast failed: $value to $T");
  }

  // Default value if the type is not matched
  static T _defaultValueForType<T>() {
    switch (T) {
      case String:
        return '' as T;
      case int:
        return 0 as T;
      case double:
        return 0.0 as T;
      case bool:
        return false as T;
      case List:
        return [] as T;
      default:
        return null as T;
    }
  }

  // Converts a List of dynamic data into a List of parsed objects (based on the fromJson function)
  static List<T> mapList<T>(dynamic data, T Function(dynamic) fromJson) {
    if (data == null || data is! List) return [];
    return data.map((e) => fromJson(e)).toList();
  }
}
