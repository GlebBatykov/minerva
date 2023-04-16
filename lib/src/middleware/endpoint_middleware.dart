part of minerva_middleware;

class EndpointMiddleware extends Middleware {
  final AuthAccessValidator _accessValidator = AuthAccessValidator();

  final PathComparator _comparator = PathComparator();

  final FilterMatcher _filterMatcher = FilterMatcher();

  @override
  Future<Object?> handle(
    MiddlewareContext context,
    MiddlewarePipelineNode? next,
  ) async {
    final request = context.request;

    final serverContext = context.context;

    if (request.isUpgradeRequest) {
      return await _handleWebSocket(
        context: serverContext,
        request: request,
        endpoints: context.webSocketEndpoints,
      );
    } else {
      return await _handleHttpRequest(
        context: serverContext,
        request: request,
        endpoints: context.httpEndpoints,
      );
    }
  }

  Future<Object?> _handleHttpRequest({
    required ServerContext context,
    required MinervaRequest request,
    required List<Endpoint> endpoints,
  }) async {
    final selectedEndpoints =
        endpoints.where((e) => e.method.value == request.method).toList();

    if (selectedEndpoints.isEmpty) {
      return NotFoundResult();
    }

    final endpoint = await _getEndpoint(selectedEndpoints, request);

    if (endpoint == null) {
      return NotFoundResult();
    }

    final authOptions = endpoint.authOptions;

    if (!_accessValidator.isHaveAccess(request, authOptions)) {
      return UnauthorizedResult();
    }

    try {
      final result = await endpoint.handler(context, request);

      return result;
    } catch (object, stackTrace) {
      if (endpoint.errorHandler == null) {
        throw EndpointHandleException(
          error: object,
          stackTrace: stackTrace,
          request: request,
        );
      } else {
        try {
          return endpoint.errorHandler!.call(context, request, object);
        } catch (object, stackTrace) {
          throw EndpointHandleException(
            error: object,
            stackTrace: stackTrace,
            request: request,
          );
        }
      }
    }
  }

  Future<Endpoint?> _getEndpoint(
    List<Endpoint> endpoints,
    MinervaRequest request,
  ) async {
    final matchedEndpoints = <Endpoint>[];

    for (var i = 0; i < endpoints.length; i++) {
      final endpoint = endpoints[i];

      final result = _comparator.compare(endpoint.path, request.uri.path);

      if (!result.isEqual) {
        continue;
      }

      if (endpoint.filter != null) {
        final isFilterMatch =
            await _filterMatcher.match(request, endpoint.filter!);

        if (!isFilterMatch) {
          continue;
        }
      }

      matchedEndpoints.add(endpoint);

      if (matchedEndpoints.length > 1) {
        throw MiddlewareHandleException(
          message:
              'An error occurred while searching for the endpoint. The request matched multiple endpoints.',
        );
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

  Future<Object?> _handleWebSocket({
    required ServerContext context,
    required MinervaRequest request,
    required List<WebSocketEndpoint> endpoints,
  }) async {
    final selectedEndpoints =
        endpoints.where((e) => e.path == request.uri.path).toList();

    if (selectedEndpoints.isNotEmpty) {
      final socket = await request.upgrade();

      await selectedEndpoints.first.handler(context, socket);

      return null;
    } else {
      return NotFoundResult();
    }
  }
}
