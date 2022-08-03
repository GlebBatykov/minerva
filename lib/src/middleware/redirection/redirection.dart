part of minerva_middleware;

class Redirection {
  final HttpMethod method;

  final MinervaPath path;

  final String location;

  final AuthOptions? authOptions;

  Redirection(this.method, String path, this.location, this.authOptions)
      : path = MinervaPath.parse(path);
}
