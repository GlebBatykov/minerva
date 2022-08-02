part of minerva_server;

class RouteData {
  final HttpMethod method;

  final String path;

  final String endpoint;

  final AuthOptions? authOptions;

  RouteData(this.method, this.path, this.endpoint, {this.authOptions});
}
