part of minerva_middleware;

class AuthAccessValidator {
  bool isHaveAccess(MinervaRequest request, AuthOptions? authOptions) {
    bool isHaveAccess = false;

    final authContext = request.authContext;

    if (authOptions != null) {
      final jwtOptions = authOptions.jwt;

      final cookieOptions = authOptions.cookie;

      final jwtContext = authContext.jwt;

      final cookieContext = authContext.cookie;

      if (jwtOptions == null && cookieOptions == null) {
        isHaveAccess = true;
      } else if (jwtOptions != null && jwtContext != null) {
        isHaveAccess = _isJwtHaveAccess(jwtOptions, jwtContext);
      } else if (cookieOptions != null && cookieContext != null) {
        isHaveAccess = true;
      }
    } else {
      isHaveAccess = true;
    }

    return isHaveAccess;
  }

  bool _isJwtHaveAccess(JwtAuthOptions options, JwtAuthContext context) {
    var isHaveAccess = false;

    final role = context.role;

    if ((options.permissionLevel != null &&
        (role != null &&
            role.permissionLevel != null &&
            options.permissionLevel! <= role.permissionLevel!))) {
      isHaveAccess = true;
    }

    if (!isHaveAccess &&
        (options.roles != null &&
            role != null &&
            options.roles!.contains(role.name))) {
      isHaveAccess = true;
    }

    if (!isHaveAccess &&
        options.roles == null &&
        options.permissionLevel == null) {
      isHaveAccess = true;
    }

    return isHaveAccess;
  }
}
