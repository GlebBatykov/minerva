part of minerva_middleware;

typedef CookieIsAuthorizedCallback = FutureOr<bool> Function(
    ServerContext context, List<Cookie> cookies);

class CookieAuthMiddleware extends Middleware {
  final CookieIsAuthorizedCallback _cookieIsAuthorized;

  CookieAuthMiddleware({required CookieIsAuthorizedCallback cookieIsAuthorized})
      : _cookieIsAuthorized = cookieIsAuthorized;

  @override
  Future<dynamic> handle(
      MiddlewareContext context, MiddlewarePipelineNode? next) async {
    var isAuthorized =
        await _cookieIsAuthorized(context.context, context.request.cookies);

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
