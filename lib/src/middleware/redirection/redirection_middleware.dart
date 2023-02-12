part of minerva_middleware;

/// Middleware which is used to redirect incoming requests.
class RedirectionMiddleware extends Middleware {
  final AuthAccessValidator _accessValidator = AuthAccessValidator();

  final PathComparator _comparator = PathComparator();

  late final List<Redirection> _redirections;

  RedirectionMiddleware({required List<RedirectionData> redirections})
      : _redirections = redirections
            .map((e) => Redirection(e.method, MinervaPath.parse(e.path),
                RedirectionLocation(e.location), e.authOptions))
            .toList();

  @override
  Future<dynamic> handle(
      MiddlewareContext context, MiddlewarePipelineNode? next) async {
    final request = context.request;

    final redirections = _redirections
        .where((element) => element.method.value == request.method)
        .toList();

    if (redirections.isNotEmpty) {
      final redirection = _getRedirection(redirections, request);

      if (redirection != null) {
        final authOptions = redirection.authOptions;

        if (!_accessValidator.isHaveAccess(request, authOptions)) {
          return UnauthorizedResult();
        } else {
          final location = _getLocation(redirection);

          return RedirectionResult(location);
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
    final matchedRedirection = <Redirection>[];

    for (var i = 0; i < redirections.length; i++) {
      final result =
          _comparator.compare(redirections[i].path, request.uri.path);

      if (result.isEqual) {
        matchedRedirection.add(redirections[i]);

        if (matchedRedirection.length > 1) {
          throw MiddlewareHandleException(
              message:
                  'An error occurred while searching for the redirection. The request matched multiple redirections.');
        } else {
          if (result.pathParameters != null) {
            redirections[i].addPathParameters(result.pathParameters!);
          }
        }
      }
    }

    if (matchedRedirection.isEmpty) {
      return null;
    } else {
      return matchedRedirection.first;
    }
  }

  String _getLocation(Redirection redirection) {
    var location = redirection.location.toString();

    for (final parameter in redirection.pathParameters.entries) {
      location =
          location.replaceAll(':${parameter.key}', parameter.value.toString());
    }

    return location;
  }
}
