part of minerva_routing;

typedef EndpointHandler = FutureOr<dynamic> Function(
    ServerContext context, MinervaRequest request);

typedef EndpointErrorHandler = FutureOr<dynamic> Function(
    ServerContext context, MinervaRequest request, Object error);

class Endpoint {
  final HttpMethod method;

  final MinervaPath path;

  final EndpointHandler handler;

  final EndpointErrorHandler? errorHandler;

  final AuthOptions? authOptions;

  final Filter? filter;

  Endpoint(this.method, String path, this.handler, this.errorHandler,
      this.authOptions, this.filter)
      : path = MinervaPath.parse(path);
}
