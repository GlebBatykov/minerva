part of minerva_middleware;

/// Base class for middleware classes for handle requests.
abstract class Middleware {
  const Middleware();

  /// Used for deferred initialization at server startup.
  FutureOr<void> initialize(ServerContext context) {}

  /// Used for processing requests in the request processing pipeline.
  FutureOr<dynamic> handle(
      MiddlewareContext context, MiddlewarePipelineNode? next);

  /// Used for dispose resources.
  FutureOr<void> dispose(ServerContext context) {}
}
