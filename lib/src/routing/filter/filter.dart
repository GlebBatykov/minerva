part of minerva_routing;

class RequestFilter {
  final ContentTypeFilter? contentType;

  final QueryParametersFilter? queryParameters;

  final BodyFilter? body;

  const RequestFilter({this.contentType, this.queryParameters, this.body});
}
