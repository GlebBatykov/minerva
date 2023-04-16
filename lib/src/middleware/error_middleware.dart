part of minerva_middleware;

/// It is used to handle errors that occur when processing requests in the request processing pipeline.
class ErrorMiddleware extends Middleware {
  /// Handler for error handling.
  ///
  /// If it is not set, the default handler is used.
  final EndpointErrorHandler? handler;

  /// Determines whether stack trace is displayed in the response, in case of an unhandled error when processing the request.
  final bool trace;

  late final LogPipeline _logPipeline;

  ErrorMiddleware({
    this.handler,
    this.trace = true,
  });

  @override
  void initialize(ServerContext context) {
    _logPipeline = context.logPipeline;
  }

  @override
  Future<dynamic> handle(
    MiddlewareContext context,
    MiddlewarePipelineNode? next,
  ) async {
    if (next == null) {
      return NotFoundResult();
    }

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
          final exception = RequestHandleException(object, stackTrace);

          _logPipeline.error(exception);

          return _buildErrorResult(exception);
        }
      }
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
