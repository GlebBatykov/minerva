part of minerva_middleware;

class EndpointMiddleware extends Middleware {
  final AuthAccessValidator _accessValidator = AuthAccessValidator();

  final PathComparator _comparator = PathComparator();

  final FilterMatcher _filterMatcher = FilterMatcher();

  @override
  Future<dynamic> handle(
      MiddlewareContext context, MiddlewarePipelineNode? next) async {
    var request = context.request;

    var endpoints = context.endpoints
        .where((element) => element.method.value == request.method)
        .toList();

    if (endpoints.isNotEmpty) {
      var endpoint = await _getEndpoint(endpoints, request);

      if (endpoint != null) {
        var authOptions = endpoint.authOptions;

        if (!_accessValidator.isHaveAccess(request, authOptions)) {
          return UnauthorizedResult();
        } else {
          try {
            var result = await endpoint.handler(context.context, request);

            return result;
          } catch (object, stackTrace) {
            if (endpoint.errorHandler == null) {
              throw EndpointHandleException(object, stackTrace, request);
            } else {
              try {
                return endpoint.errorHandler!
                    .call(context.context, request, object);
              } catch (object, stackTrace) {
                throw EndpointHandleException(object, stackTrace, request);
              }
            }
          }
        }
      } else {
        return NotFoundResult();
      }
    } else {
      return NotFoundResult();
    }
  }

  Future<Endpoint?> _getEndpoint(
      List<Endpoint> endpoints, MinervaRequest request) async {
    var matchedEndpoints = <Endpoint>[];

    for (var i = 0; i < endpoints.length; i++) {
      var endpoint = endpoints[i];

      var result = _comparator.compare(endpoint.path, request.uri.path);

      if (!result.isEqual) {
        continue;
      }

      if (endpoint.filter != null) {
        var isFilterMatch =
            await _filterMatcher.match(request, endpoint.filter!);

        if (!isFilterMatch) {
          continue;
        }
      }

      matchedEndpoints.add(endpoint);

      if (matchedEndpoints.length > 1) {
        throw MiddlewareHandleException(
            message:
                'An error occurred while searching for the endpoint. The request matched multiple endpoints.');
      }

      if (result.pathParameters != null) {
        request.addPathParameters(result.pathParameters!);
      }
    }

    if (matchedEndpoints.isEmpty) {
      return null;
    } else {
      return matchedEndpoints.first;
    }
  }
}
