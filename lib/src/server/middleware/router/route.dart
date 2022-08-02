part of minerva_server;

class Route {
  final HttpMethod method;

  final String path;

  final String endpoint;

  final AuthOptions? authOptions;

  Route(this.method, this.path, this.endpoint, this.authOptions);
}
