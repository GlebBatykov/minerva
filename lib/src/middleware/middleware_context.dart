part of minerva_middleware;

class MiddlewareContext {
  final MinervaRequest request;

  final List<Endpoint> endpoints;

  final ServerContext context;

  MiddlewareContext(this.request, this.endpoints, this.context);
}
