part of minerva_routing;

class Filter {
  final ContentTypeFilter? contentType;

  final QueryParametersFilter? queryParameters;

  final BodyFilter? body;

  Filter({this.contentType, this.queryParameters, this.body});
}