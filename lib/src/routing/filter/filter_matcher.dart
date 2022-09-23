part of minerva_routing;

class FilterMatcher {
  final QueryParametersMatcher _queryParametersMatcher =
      QueryParametersMatcher();

  final BodyMatcher _bodyMatcher = BodyMatcher();

  Future<bool> match(MinervaRequest request, RequestFilter filter) async {
    if (filter.contentType != null &&
        (request.headers.contentType == null ||
            !filter.contentType!.accepts
                .contains(request.headers.contentType!.mimeType))) {
      return false;
    }

    if (filter.queryParameters != null &&
        !_queryParametersMatcher.match(
            request.uri.queryParameters, filter.queryParameters!)) {
      return false;
    }

    if (filter.body != null &&
        !await _bodyMatcher.match(request, filter.body!)) {
      return false;
    }

    return true;
  }
}
