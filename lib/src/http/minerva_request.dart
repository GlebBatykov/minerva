part of minerva_http;

class MinervaRequest {
  final HttpRequest _request;

  final AuthContext _authContext = AuthContext();

  final Map<String, num> _pathParameters = {};

  final RequestBody _body;

  bool _isUpgraded = false;

  AuthContext get authContext => _authContext;

  /// The session for the given request.
  ///
  /// If the session is being initialized by this call, [HttpSession.isNew] is true for the returned session. See [HttpServer.sessionTimeout] on how to change default timeout.
  HttpSession get session => _request.session;

  String get method => _request.method;

  Uri get uri => _request.uri;

  HttpHeaders get headers => _request.headers;

  RequestBody get body => _body;

  Future<int> get length => _request.length;

  List<Cookie> get cookies => _request.cookies;

  X509Certificate? get certificate => _request.certificate;

  HttpConnectionInfo? get connectionInfo => _request.connectionInfo;

  int get connectionLength => _request.contentLength;

  Uri get requestedUri => _request.requestedUri;

  bool get persistentConnection => _request.persistentConnection;

  String get protocolVersion => _request.protocolVersion;

  Map<String, num> get pathParameters => Map.unmodifiable(_pathParameters);

  bool get isUpgradeRequest => WebSocketTransformer.isUpgradeRequest(_request);

  bool get isUpgraded => _isUpgraded;

  MinervaRequest(HttpRequest request)
      : _request = request,
        _body = RequestBody(request.asBroadcastStream(), request.headers);

  Future<WebSocket> upgrade(
      {dynamic Function(List<String>)? protocolSelector,
      CompressionOptions compression =
          CompressionOptions.compressionDefault}) async {
    var socket = await WebSocketTransformer.upgrade(_request,
        protocolSelector: protocolSelector, compression: compression);

    _isUpgraded = true;

    return socket;
  }

  void addPathParameter(String key, num value) {
    _pathParameters[key] = value;
  }

  void addPathParameters(Map<String, num> pathParameters) {
    _pathParameters.addAll(pathParameters);
  }

  void removePathParameter(String key) {
    _pathParameters.remove(key);
  }

  void removePathParameters() {
    _pathParameters.clear();
  }
}
