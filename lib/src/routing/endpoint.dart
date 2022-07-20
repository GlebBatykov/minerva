part of minerva_routing;

typedef EndpointHandler = FutureOr<Result> Function(
    ServerContext context, MinervaRequest request);

typedef EndpointErrorHandler = FutureOr<Result> Function(
    ServerContext context, MinervaRequest request, Object error);

class Endpoint {
  final HttpMethod method;

  final String path;

  final EndpointHandler handler;

  final EndpointErrorHandler? errorHandler;

  final List<String> roles;

  Endpoint(this.method, this.path, this.handler, this.errorHandler, this.roles);
}
