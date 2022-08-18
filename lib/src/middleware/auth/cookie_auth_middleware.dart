part of minerva_middleware;

typedef CookieIsAuthorizedCallback = FutureOr<bool> Function(
    ServerContext context, List<Cookie> cookies);

class CookieAuthMiddleware extends Middleware {
  final CookieIsAuthorizedCallback _isAuthorized;

  CookieAuthMiddleware({required CookieIsAuthorizedCallback isAuthorized})
      : _isAuthorized = isAuthorized;

  @override
  Future<dynamic> handle(
      MiddlewareContext context, MiddlewarePipelineNode? next) async {
    var isAuthorized =
        await _isAuthorized(context.context, context.request.cookies);

    if (isAuthorized) {
      var cookieContext = CookieAuthContext();

      context.request.authContext.cookie = cookieContext;
    }

    if (next != null) {
      return await next.handle(context);
    } else {
      return NotFoundResult();
    }
  }
}
