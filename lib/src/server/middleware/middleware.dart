part of minerva_server;

abstract class Middleware {
  const Middleware();

  FutureOr<Result> handle(MiddlewareContext context, PipelineNode? next);
}
