part of minerva_server;

typedef TokenVerifyCallback = FutureOr<bool> Function(
    ServerContext context, String token);

typedef GetRolesCallback = FutureOr<List<String>> Function(
    ServerContext context, String token);

class AuthMiddleware extends Middleware {
  final TokenVerifyCallback _tokenVerify;

  final GetRolesCallback? _getRoles;

  const AuthMiddleware(
      {required TokenVerifyCallback tokenVerify, GetRolesCallback? getRoles})
      : _tokenVerify = tokenVerify,
        _getRoles = getRoles;

  @override
  Future<dynamic> handle(MiddlewareContext context, PipelineNode? next) async {
    var header = context.request.headers[HttpHeaders.authorizationHeader];

    if (header != null) {
      var segments = header.first.split(' ');

      if (segments.length == 2 && segments.first == 'Bearer') {
        var token = segments[1];

        var isVerified = await _tokenVerify(context.context, token);

        if (isVerified) {
          if (_getRoles != null) {
            var roles = await _getRoles!.call(context.context, token);

            context.request.addRoles(roles);
          }
        } else {
          UnauthorizedResult();
        }
      }
    }

    if (next != null) {
      return await next.handle(context);
    } else {
      return NotFoundResult();
    }
  }
}
