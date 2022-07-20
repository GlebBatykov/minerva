part of minerva_server;

abstract class Middleware {
  const Middleware();

  FutureOr<dynamic> handle(MiddlewareContext context, PipelineNode? next);
}
