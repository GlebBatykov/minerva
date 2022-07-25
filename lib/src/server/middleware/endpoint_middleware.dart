part of minerva_server;

class EndpointMiddleware extends Middleware {
  const EndpointMiddleware();

  @override
  Future<dynamic> handle(MiddlewareContext context, PipelineNode? next) async {
    var request = context.request;

    var endpoints = context.endpoints
        .where((element) => element.method.value == context.request.method)
        .toList();

    if (endpoints.isNotEmpty) {
      Endpoint? endpoint;

      for (var i = 0; i < endpoints.length; i++) {
        if (endpoints[i].path == request.uri.path) {
          endpoint = endpoints[i];
        }
      }

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

  bool _isHaveAccess(MinervaRequest request, Endpoint endpoint) {
    bool isHaveAccess = false;

    var authOptions = endpoint.authOptions;

    var role = request.role;

    if (authOptions != null) {
      if ((authOptions.permissionLevel != null &&
          (role != null &&
              role.permissionLevel != null &&
              authOptions.permissionLevel! <= role.permissionLevel!))) {
        isHaveAccess = true;
      }

      if (!isHaveAccess &&
          (authOptions.roles != null &&
              role != null &&
              authOptions.roles!.contains(role.name))) {
        isHaveAccess = true;
      }
    } else {
      isHaveAccess = true;
    }

    return isHaveAccess;
  }
}
