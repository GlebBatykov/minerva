part of minerva_middleware;

class AuthAccessValidator {
  bool isHaveAccess(MinervaRequest request, AuthOptions? authOptions) {
    bool isHaveAccess = false;

    var authContext = request.authContext;

    if (authOptions != null) {
      var jwtOptions = authOptions.jwt;

      var cookieOptions = authOptions.cookie;

      if (jwtOptions == null && cookieOptions == null) {
        isHaveAccess = true;
      } else if (jwtOptions != null) {
        var role = authContext.jwt.role;

        isHaveAccess = _isJwtHaveAccess(jwtOptions, role);
      } else if (cookieOptions != null) {
        var isAuthorized = request.authContext.cookie.isAuthorized;

        isHaveAccess = _isCookieHaveAccess(cookieOptions, isAuthorized);
      }
    } else {
      isHaveAccess = true;
    }

    return isHaveAccess;
  }

  bool _isJwtHaveAccess(JwtAuthOptions options, Role? role) {
    var isHaveAccess = false;

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

    return isHaveAccess;
  }

  bool _isCookieHaveAccess(CookieAuthOptions options, bool isAuthorized) {
    var isHaveAccess = false;

    if (options.isAuthorized) {
      isHaveAccess = isAuthorized;
    } else {
      isHaveAccess = true;
    }

    return isHaveAccess;
  }
}
