part of minerva_routing;

typedef EndpointHandler = FutureOr<dynamic> Function(
    ServerContext context, MinervaRequest request);

typedef EndpointErrorHandler = FutureOr<dynamic> Function(
    ServerContext context, MinervaRequest request, Object error);

/// Contains information about the HTTP endpoint.
class Endpoint {
  /// HTTP method of endpoint.
  final HttpMethod method;

  /// Path of endpoint.
  final MinervaPath path;

  /// Handler of endpoint.
  final EndpointHandler handler;

  /// Error handler of endpoint. It is used to handle errors that occur during request processing.
  final EndpointErrorHandler? errorHandler;

  /// Authentication options that the incoming request must match.
  final AuthOptions? authOptions;

  /// Request filter that the incoming request must match.
  final RequestFilter? filter;

  Endpoint(this.method, String path, this.handler, this.errorHandler,
      this.authOptions, this.filter)
      : path = MinervaPath.parse(path);
}
