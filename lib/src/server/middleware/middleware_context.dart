part of minerva_server;

class MiddlewareContext {
  final MinervaRequest request;

  final List<Endpoint> endpoints;

  final ServerContext context;

  MiddlewareContext(this.request, this.endpoints, this.context);
}
