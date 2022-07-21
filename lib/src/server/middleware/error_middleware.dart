part of minerva_server;

class ErrorMiddleware extends Middleware {
  final EndpointErrorHandler? handler;

  const ErrorMiddleware({this.handler});

  @override
  Future<dynamic> handle(MiddlewareContext context, PipelineNode? next) async {
    if (next != null) {
      try {
        return await next.handle(context);
      } catch (object) {
        if (handler == null) {
          return InternalServerErrorResult(object);
        } else {
          try {
            return handler!.call(context.context, context.request, object);
          } catch (object, stackTrace) {
            return InternalServerErrorResult(
                MiddlewareHandleException(object, stackTrace));
          }
        }
      }
    } else {
      return NotFoundResult();
    }
  }
}
