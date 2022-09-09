part of minerva_middleware;

class MiddlewareContext {
  final MinervaRequest request;

  final List<Endpoint> httpEndpoints;

  final List<WebSocketEndpoint> webSocketEndponts;

  final ServerContext context;

  MiddlewareContext(
      this.request, this.httpEndpoints, this.webSocketEndponts, this.context);
}
