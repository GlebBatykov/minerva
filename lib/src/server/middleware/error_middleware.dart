part of minerva_server;

///
class ErrorMiddleware extends Middleware {
  ///
  final EndpointErrorHandler? handler;

  ///
  final bool trace;

  late final LogPipeline _logPipeline;

  ErrorMiddleware({this.handler, this.trace = true});

  @override
  void initialize(ServerContext context) {
    _logPipeline = context.logPipeline;
  }

  @override
  Future<dynamic> handle(MiddlewareContext context, PipelineNode? next) async {
    if (next != null) {
      try {
        return await next.handle(context);
      } catch (object) {
        if (handler == null) {
          _logPipeline.error(object);

          return _buildErrorResult(object);
        } else {
          try {
            return handler!.call(context.context, context.request, object);
          } catch (object, stackTrace) {
            var exception = MiddlewareHandleException(object, stackTrace,
                message:
                    'An error occurred while processing an error in the assigned error handler.');

            _logPipeline.error(exception);

            return _buildErrorResult(exception);
          }
        }
      }
    } else {
      return NotFoundResult();
    }
  }

  InternalServerErrorResult _buildErrorResult(Object error) {
    if (trace) {
      return InternalServerErrorResult(body: error);
    } else {
      return InternalServerErrorResult();
    }
  }
}
