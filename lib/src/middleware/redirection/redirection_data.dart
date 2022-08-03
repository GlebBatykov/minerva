part of minerva_middleware;

class RedirectionData {
  final HttpMethod method;

  final String path;

  final String location;

  final AuthOptions? authOptions;

  RedirectionData(this.method, this.path, this.location, {this.authOptions});
}
