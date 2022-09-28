part of minerva_middleware;

class EndpointMiddleware extends Middleware {
  final AuthAccessValidator _accessValidator = AuthAccessValidator();

  final PathComparator _comparator = PathComparator();

  final FilterMatcher _filterMatcher = FilterMatcher();

  @override
  Future<dynamic> handle(
      MiddlewareContext context, MiddlewarePipelineNode? next) async {
    var request = context.request;

    var serverContext = context.context;

    if (request.isUpgradeRequest) {
      return await _handleWebSocket(
          serverContext, request, context.webSocketEndponts);
    } else {
      return await _handleHttpRequest(
          serverContext, request, context.httpEndpoints);
    }
  }

  Future<dynamic> _handleHttpRequest(ServerContext context,
      MinervaRequest request, List<EndpointData> endpoints) async {
    var selectedEndpoints = endpoints
        .where((element) => element.method.value == request.method)
        .toList();

    if (selectedEndpoints.isEmpty) {
      return NotFoundResult();
    }

    var endpoint = await _getEndpoint(selectedEndpoints, request);

    if (endpoint == null) {
      return NotFoundResult();
    }

    var authOptions = endpoint.authOptions;

    if (!_accessValidator.isHaveAccess(request, authOptions)) {
      return UnauthorizedResult();
    }

    try {
      var result = await endpoint.handler(context, request);

      return result;
    } catch (object, stackTrace) {
      if (endpoint.errorHandler == null) {
        throw EndpointHandleException(object, stackTrace, request);
      } else {
        try {
          return endpoint.errorHandler!.call(context, request, object);
        } catch (object, stackTrace) {
          throw EndpointHandleException(object, stackTrace, request);
        }
      }
    }
  }

  Future<EndpointData?> _getEndpoint(
      List<EndpointData> endpoints, MinervaRequest request) async {
    var matchedEndpoints = <EndpointData>[];

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

  Future<dynamic> _handleWebSocket(ServerContext context,
      MinervaRequest request, List<WebSocketEndpointData> endpoints) async {
    var selectedEndpoints =
        endpoints.where((element) => element.path == request.uri.path).toList();

    if (selectedEndpoints.isNotEmpty) {
      var socket = await request.upgrade();

      await selectedEndpoints.first.handler(context, socket);
    } else {
      return NotFoundResult();
    }
  }
}
