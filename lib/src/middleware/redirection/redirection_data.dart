part of minerva_middleware;

/// Contains data about redirection.
class RedirectionData {
  /// HTTP method of request and redirection.
  final HttpMethod method;

  /// Incoming request path.
  final String path;

  /// The address where the request should be redirected.
  final String location;

  /// Authorization context.
  final AuthOptions? authOptions;

  RedirectionData(
      {required this.method,
      required this.path,
      required this.location,
      this.authOptions});
}
