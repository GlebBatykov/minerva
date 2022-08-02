part of minerva_middleware;

class Route {
  final HttpMethod method;

  final String path;

  final String endpoint;

  final AuthOptions? authOptions;

  Route(this.method, this.path, this.endpoint, this.authOptions);
}
