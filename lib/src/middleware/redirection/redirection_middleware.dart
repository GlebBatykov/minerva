part of minerva_middleware;

class RedirectionMiddleware extends Middleware {
  final AuthAccessValidator _accessValidator = AuthAccessValidator();

  final PathComparator _comparator = PathComparator();

  late final List<Redirection> _redirections;

  RedirectionMiddleware({required List<RedirectionData> redirections}) {
    _redirections = redirections
        .map((e) => Redirection(e.method, e.path, e.location, e.authOptions))
        .toList();
  }

  @override
  Future<dynamic> handle(MiddlewareContext context, PipelineNode? next) async {
    var request = context.request;

    var redirections = _redirections
        .where((element) => element.method.value == request.method)
        .toList();

    if (redirections.isNotEmpty) {
      var redirection = _getRedirection(redirections, request);

      if (redirection != null) {
        var authOptions = redirection.authOptions;

        if (!_accessValidator.isHaveAccess(request, authOptions)) {
          return UnauthorizedResult();
        } else {
          var headers = <String, Object>{
            HttpHeaders.locationHeader: redirection.location
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

  Redirection? _getRedirection(
      List<Redirection> redirections, MinervaRequest request) {
    List<Redirection> matchedRedirection = [];

    for (var i = 0; i < redirections.length; i++) {
      var result = _comparator.compare(redirections[i].path, request.uri.path);

      if (result.isEqual) {
        matchedRedirection.add(redirections[i]);

        if (matchedRedirection.length > 1) {
          throw MiddlewareHandleException(
              MatchedMultipleEndpointsException(), StackTrace.current,
              message:
                  'An error occurred while searching for the redirection. The request matched multiple redirections.');
        } else {
          if (result.pathParameters != null) {
            request.addPathParameters(result.pathParameters!);
          }
        }
      }
    }

    if (matchedRedirection.isEmpty) {
      return null;
    } else {
      return matchedRedirection.first;
    }

    // var routes =
    //     redirections.where((element) => element.path.path == request.uri.path);

    // if (routes.isEmpty) {
    //   return null;
    // } else if (routes.length == 1) {
    //   return routes.first;
    // } else {
    //   throw MiddlewareHandleException(
    //       MatchedMultipleRoutesException(), StackTrace.current,
    //       message:
    //           'An error occurred while searching for the route. The request matched multiple endpoints.');
    // }
  }
}
