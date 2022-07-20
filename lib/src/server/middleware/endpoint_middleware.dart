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
        if (endpoint.roles.isNotEmpty &&
            request.roles.intersection(endpoint.roles).isEmpty) {
          return UnauthorizedResult();
        } else {
          try {
            var result = await endpoint.handler(context.context, request);

            return result;
          } catch (object, stackTrace) {
            if (endpoint.errorHandler == null) {
              throw EndpointHandleException(object, stackTrace, request);
            } else {
              try {
                return endpoint.errorHandler!
                    .call(context.context, request, object);
              } catch (object, stackTrace) {
                throw EndpointHandleException(object, stackTrace, request);
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
}
