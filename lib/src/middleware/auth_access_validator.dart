part of minerva_middleware;

class AuthAccessValidator {
  bool isHaveAccess(MinervaRequest request, AuthOptions? authOptions) {
    bool isHaveAccess = false;

    var authContext = request.authContext;

    if (authOptions != null) {
      var jwtOptions = authOptions.jwt;

      var cookieOptions = authOptions.cookie;

      var jwtContext = authContext.jwt;

      var cookieContext = authContext.cookie;

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

    var role = context.role;

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
