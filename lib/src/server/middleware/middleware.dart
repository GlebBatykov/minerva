part of minerva_server;

abstract class Middleware {
  const Middleware();

  FutureOr<void> initialize(ServerContext context) {}

  FutureOr<dynamic> handle(MiddlewareContext context, PipelineNode? next);

  FutureOr<void> dispose(ServerContext context) {}
}
