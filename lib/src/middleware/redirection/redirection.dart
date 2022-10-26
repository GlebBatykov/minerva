part of minerva_middleware;

///
class Redirection {
  ///
  final HttpMethod method;

  ///
  final MinervaPath path;

  ///
  final RedirectionLocation location;

  ///
  final AuthOptions? authOptions;

  final Map<String, num> _pathParameters = {};

  ///
  Map<String, num> get pathParameters => Map.unmodifiable(_pathParameters);

  Redirection(this.method, this.path, this.location, this.authOptions);

  ///
  void addPathParameter(String key, num value) {
    _pathParameters[key] = value;
  }

  ///
  void addPathParameters(Map<String, num> pathParameters) {
    _pathParameters.addAll(pathParameters);
  }

  ///
  void removePathParameter(String key) {
    _pathParameters.remove(key);
  }

  ///
  void removePathParameters() {
    _pathParameters.clear();
  }
}
