part of minerva_routing;

/// The request filter is used to filter out requests that do not match it.
class RequestFilter {
  /// Filter of content-type.
  final ContentTypeFilter? contentType;

  /// Filter of query parameters.
  final QueryParametersFilter? queryParameters;

  /// Filter of request body.
  final BodyFilter? body;

  const RequestFilter({this.contentType, this.queryParameters, this.body});
}
