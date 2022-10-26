part of minerva_routing;

enum JsonFieldType { int, double, string, bool, map, list, num }

/// Used when filtering requests, to check for the presence of json field in the json request body.
class JsonField {
  /// Name of json field.
  final String name;

  /// Type of json field.
  final JsonFieldType? type;

  const JsonField({required this.name, this.type});
}

/// The body filter is used to filter out requests that do not match it.
class JsonFilter extends BodyFilter {
  /// Json fields that the request should contain.
  final List<JsonField> fields;

  const JsonFilter({required this.fields});
}
