part of minerva_routing;

enum QueryParameterType { num, int, double, bool }

/// Used in query parameters filter.
class QueryParameter {
  /// Name of query parameter.
  final String name;

  /// Type of query parameter.
  final QueryParameterType? type;

  const QueryParameter({required this.name, this.type});
}
