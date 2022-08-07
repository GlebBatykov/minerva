part of minerva_routing;

enum JsonFieldType { int, double, string, bool, map, list }

class JsonField {
  final String name;

  final JsonFieldType? type;

  JsonField({required this.name, this.type});
}

class JsonFilter extends BodyFilter {
  final List<JsonField> fields;

  JsonFilter(this.fields);
}