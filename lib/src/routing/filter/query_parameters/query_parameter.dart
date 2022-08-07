part of minerva_routing;

enum QueryParameterType { num, int, double, bool }

class QueryParameter {
  final String name;

  final QueryParameterType? type;

  const QueryParameter({required this.name, this.type});
}
