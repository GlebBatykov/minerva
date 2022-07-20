part of minerva_http;

class MinervaRequest {
  final HttpRequest _request;

  Role? _role;

  Role? get role => _role;

  HttpSession get session => _request.session;

  String get method => _request.method;

  Uri get uri => _request.uri;

  HttpHeaders get headers => _request.headers;

  Future<String> get body => utf8.decodeStream(_request);

  Future<Map<String, dynamic>> get json =>
      body.then(((value) => jsonDecode(value)));

  Future<int> get length => _request.length;

  List<Cookie> get cookies => _request.cookies;

  X509Certificate? get certificate => _request.certificate;

  HttpConnectionInfo? get connectionInfo => _request.connectionInfo;

  int get connectionLength => _request.contentLength;

  Uri get requestedUri => _request.requestedUri;

  bool get persistentConnection => _request.persistentConnection;

  String get protocolVersion => _request.protocolVersion;

  MinervaRequest(HttpRequest request) : _request = request;

  void setRole(Role role) {
    _role = role;
  }

  void removeRole() {
    _role = null;
  }
}
