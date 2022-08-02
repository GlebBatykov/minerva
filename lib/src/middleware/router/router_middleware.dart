part of minerva_middleware;

class RouterMiddleware extends Middleware {
  late final List<Route> _routes;

  RouterMiddleware({required List<RouteData> routes}) {
    _routes = routes
        .map((e) => Route(e.method, e.path, e.endpoint, e.authOptions))
        .toList();
  }

  @override
  Future<dynamic> handle(MiddlewareContext context, PipelineNode? next) async {
    var request = context.request;

    var routes = _routes
        .where((element) => element.method.value == request.method)
        .toList();

    if (routes.isNotEmpty) {
      var route = _getRoute(routes, request);

      if (route != null) {
        if (!_isHaveAccess(request, route)) {
          return UnauthorizedResult();
        } else {
          var headers = <String, Object>{
            HttpHeaders.locationHeader: route.endpoint
          };

          return Result(
              statusCode: 301, headers: MinervaHttpHeaders(headers: headers));
        }
      }
    }

    if (next != null) {
      return await next.handle(context);
    } else {
      return NotFoundResult();
    }
  }

  Route? _getRoute(List<Route> routes, MinervaRequest request) {
    var routes = _routes.where((element) => element.path == request.uri.path);

    if (routes.isEmpty) {
      return null;
    } else if (routes.length == 1) {
      return routes.first;
    } else {
      throw MiddlewareHandleException(
          MatchedMultipleRoutesException(), StackTrace.current,
          message:
              'An error occurred while searching for the route. The request matched multiple endpoints.');
    }
  }

  bool _isHaveAccess(MinervaRequest request, Route route) {
    bool isHaveAccess = false;

    var authOptions = route.authOptions;

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
