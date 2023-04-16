part of minerva_middleware;

/// Used in middlewares, it contains the data of the current server instance, as well as the data of the incoming request.
class MiddlewareContext {
  /// Context of incoming request.
  final MinervaRequest request;

  /// HTTP endpoints.
  final List<Endpoint> httpEndpoints;

  /// Websocket endpoints.
  final List<WebSocketEndpoint> webSocketEndpoints;

  /// Context of current server instance.
  final ServerContext context;

  MiddlewareContext({
    required this.request,
    required this.httpEndpoints,
    required this.webSocketEndpoints,
    required this.context,
  });
}
