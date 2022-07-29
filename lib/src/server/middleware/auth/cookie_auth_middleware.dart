part of minerva_server;

typedef CookieIsAuthorizedCallback = FutureOr<bool> Function(
    ServerContext context, List<Cookie> cookies);

class CookieAuthMiddleware extends Middleware {
  final CookieIsAuthorizedCallback _cookieIsAuthorized;

  CookieAuthMiddleware({required CookieIsAuthorizedCallback cookieIsAuthorized})
      : _cookieIsAuthorized = cookieIsAuthorized;

  @override
  Future<dynamic> handle(MiddlewareContext context, PipelineNode? next) async {
    var isAuthorized =
        await _cookieIsAuthorized(context.context, context.request.cookies);

    context.request.authContext.cookie.isAuthorized = isAuthorized;

    if (next != null) {
      return await next.handle(context);
    } else {
      return NotFoundResult();
    }
  }
}
