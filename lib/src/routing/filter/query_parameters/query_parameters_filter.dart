part of minerva_routing;

/// The query parameters filter is used to filter out requests that do not match it.
class QueryParametersFilter {
  /// Query parameters that the request should contain.
  final List<QueryParameter> parameters;

  const QueryParametersFilter({required this.parameters});
}
