part of minerva_middleware;

typedef TokenVerifyCallback = FutureOr<bool> Function(
    ServerContext context, String token);

typedef GetRolesCallback = FutureOr<Role> Function(
    ServerContext context, String token);

/// Middleware which is used for JWT authentication.
class JwtAuthMiddleware extends Middleware {
  final TokenVerifyCallback _tokenVerify;

  final GetRolesCallback? _getRole;

  const JwtAuthMiddleware(
      {required TokenVerifyCallback tokenVerify, GetRolesCallback? getRole})
      : _tokenVerify = tokenVerify,
        _getRole = getRole;

  @override
  Future<dynamic> handle(
      MiddlewareContext context, MiddlewarePipelineNode? next) async {
    final header = context.request.headers[HttpHeaders.authorizationHeader];

    if (header != null) {
      final segments = header.first.split(' ');

      if (segments.length == 2 && segments.first == 'Bearer') {
        final token = segments[1];

        final isVerified = await _tokenVerify(context.context, token);

        if (isVerified) {
          final jwtContext = JwtAuthContext(token: token);

          if (_getRole != null) {
            final role = await _getRole!.call(context.context, token);

            jwtContext.role = role;
          }

          context.request.authContext.jwt = jwtContext;
        } else {
          return UnauthorizedResult();
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
