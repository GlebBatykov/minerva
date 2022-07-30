part of minerva_server;

class EndpointMiddleware extends Middleware {
  final PathComparator _comparator = PathComparator();

  @override
  Future<dynamic> handle(MiddlewareContext context, PipelineNode? next) async {
    var request = context.request;

    var endpoints = context.endpoints
        .where((element) => element.method.value == context.request.method)
        .toList();

    if (endpoints.isNotEmpty) {
      var endpoint = _getEndpoint(endpoints, request);

      if (endpoint != null) {
        if (!_isHaveAccess(request, endpoint)) {
          return UnauthorizedResult();
        } else {
          try {
            var result = await endpoint.handler(context.context, request);

            return result;
          } catch (object, stackTrace) {
            if (endpoint.errorHandler == null) {
              throw EndpointHandleException(object, stackTrace, request,
                  message: 'An error occurred when processing the endpoint.');
            } else {
              try {
                return endpoint.errorHandler!
                    .call(context.context, request, object);
              } catch (object, stackTrace) {
                throw EndpointHandleException(object, stackTrace, request,
                    message:
                        'An error occurred in the endpoint error handler.');
              }
            }
          }
        }
      } else {
        return NotFoundResult();
      }
    } else {
      return NotFoundResult();
    }
  }

  Endpoint? _getEndpoint(List<Endpoint> endpoints, MinervaRequest request) {
    List<Endpoint> matchedEndpoints = [];

    for (var i = 0; i < endpoints.length; i++) {
      var result = _comparator.compare(endpoints[i], request.uri.path);

      if (result.isEqual) {
        matchedEndpoints.add(endpoints[i]);

        if (matchedEndpoints.length > 1) {
          throw MiddlewareHandleException(
              MatchedMultipleEndpointsException(), StackTrace.current,
              message:
                  'An error occurred while searching for the endpoint. The request matched multiple endpoints.');
        } else {
          if (result.pathParameters != null) {
            request.addPathParameters(result.pathParameters!);
          }
        }
      }
    }

    if (matchedEndpoints.isEmpty) {
      return null;
    } else {
      return matchedEndpoints.first;
    }
  }

  bool _isHaveAccess(MinervaRequest request, Endpoint endpoint) {
    bool isHaveAccess = false;

    var authOptions = endpoint.authOptions;

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
