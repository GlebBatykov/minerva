part of minerva_middleware;

class EndpointMiddleware extends Middleware {
  final AuthAccessValidator _accessValidator = AuthAccessValidator();

  final PathComparator _comparator = PathComparator();

  @override
  Future<dynamic> handle(
      MiddlewareContext context, MiddlewarePipelineNode? next) async {
    var request = context.request;

    var endpoints = context.endpoints
        .where((element) => element.method.value == request.method)
        .toList();

    if (endpoints.isNotEmpty) {
      var endpoint = _getEndpoint(endpoints, request);

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

  Endpoint? _getEndpoint(List<Endpoint> endpoints, MinervaRequest request) {
    var matchedEndpoints = <Endpoint>[];

    for (var i = 0; i < endpoints.length; i++) {
      var result = _comparator.compare(endpoints[i].path, request.uri.path);

      if (result.isEqual) {
        matchedEndpoints.add(endpoints[i]);

        if (matchedEndpoints.length > 1) {
          throw MiddlewareHandleException(
              message:
                  'An error occurred while searching for the endpoint. The request matched multiple endpoints.');
        } else {
          if (result.pathParameters != null) {
            request.addPathParameters(result.pathParameters!);
          }
        }
      }
    }

    if (matchedEndpoints.isEmpty) {
      return null;
    } else {
      return matchedEndpoints.first;
    }
  }
}
