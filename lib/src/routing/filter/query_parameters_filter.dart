part of minerva_routing;

enum QueryParameterType { int, double, bool }

class QueryParameter {
  final String name;

  final QueryParameterType? type;

  QueryParameter({required this.name, this.type});
}

class QueryParametersFilter {
  final List<QueryParameter> parameters;

  QueryParametersFilter(this.parameters);
}
