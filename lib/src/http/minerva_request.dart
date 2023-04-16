part of minerva_http;

/// Used when processing incoming requests. Contains the request data.
class MinervaRequest {
  final HttpRequest _request;

  final AuthContext _authContext = AuthContext();

  final Map<String, num> _pathParameters = {};

  final RequestBody _body;

  bool _isUpgraded = false;

  /// Authorization context of the request.
  AuthContext get authContext => _authContext;

  /// The session for the given request.
  ///
  /// If the session is being initialized by this call, [HttpSession.isNew] is true for the returned session. See [HttpServer.sessionTimeout] on how to change default timeout.
  HttpSession get session => _request.session;

  /// The method, such as 'GET' or 'POST', for the request.
  String get method => _request.method;

  /// The URI for the request.
  Uri get uri => _request.uri;

  /// The request headers.
  HttpHeaders get headers => _request.headers;

  /// The body of request.
  RequestBody get body => _body;

  /// The number of elements in this stream.
  ///
  /// Waits for all elements of this stream. When this stream ends, the returned future is completed with the number of elements.
  ///
  /// If this stream emits an error, the returned future is completed with that error, and processing stops.
  ///
  /// This operation listens to this stream, and a non-broadcast stream cannot be reused after finding its length.
  Future<int> get length => _request.length;

  /// The cookies in the request, from the "Cookie" headers.
  List<Cookie> get cookies => _request.cookies;

  /// The client certificate of the client making the request.
  ///
  /// This value is null if the connection is not a secure TLS or SSL connection, or if the server does not request a client certificate, or if the client does not provide one.
  X509Certificate? get certificate => _request.certificate;

  /// Information about the client connection.
  ///
  /// Returns null if the socket is not available.
  HttpConnectionInfo? get connectionInfo => _request.connectionInfo;

  /// The content length of the request body.
  ///
  /// If the size of the request body is not known in advance, this value is -1.
  int get connectionLength => _request.contentLength;

  /// The requested URI for the request.
  ///
  /// The returned URI is reconstructed by using http-header fields, to access otherwise lost information, e.g. host and scheme.
  ///
  /// To reconstruct the scheme, first 'X-Forwarded-Proto' is checked, and then falling back to server type.
  ///
  /// To reconstruct the host, first 'X-Forwarded-Host' is checked, then 'Host' and finally calling back to server.
  Uri get requestedUri => _request.requestedUri;

  /// The persistent connection state signaled by the client.
  bool get persistentConnection => _request.persistentConnection;

  /// The HTTP protocol version used in the request, either "1.0" or "1.1".
  String get protocolVersion => _request.protocolVersion;

  ///
  Map<String, num> get pathParameters => Map.unmodifiable(_pathParameters);

  /// Checks whether the request is a valid WebSocket upgrade request.
  bool get isUpgradeRequest => WebSocketTransformer.isUpgradeRequest(_request);

  /// Checks whether the update request was made before the websocket.
  bool get isUpgraded => _isUpgraded;

  MinervaRequest(HttpRequest request, Utf8Converter converter)
      : _request = request,
        _body = RequestBody(
          dataStream: request,
          headers: request.headers,
          converter: converter,
        );

  /// Upgrades a [HttpRequest] to a [WebSocket] connection. If the request is not a valid WebSocket upgrade request an HTTP response with status code 500 will be returned. Otherwise the returned future will complete with the [WebSocket] when the upgrade process is complete.
  ///
  /// If [protocolSelector] is provided, [protocolSelector] will be called to select what protocol to use, if any were provided by the client. [protocolSelector] is should return either a [String] or a [Future] completing with a [String]. The [String] must exist in the list of protocols.
  ///
  /// If [compression] is provided, the [WebSocket] created will be configured to negotiate with the specified [CompressionOptions]. If none is specified then the [WebSocket] will be created with the default [CompressionOptions].
  Future<WebSocket> upgrade({
    dynamic Function(List<String>)? protocolSelector,
    CompressionOptions compression = CompressionOptions.compressionDefault,
  }) async {
    final socket = await WebSocketTransformer.upgrade(
      _request,
      protocolSelector: protocolSelector,
      compression: compression,
    );

    _isUpgraded = true;

    return socket;
  }

  /// Adds path parameter to request.
  void addPathParameter(String key, num value) {
    _pathParameters[key] = value;
  }

  /// Adds path parameters to request.
  void addPathParameters(Map<String, num> pathParameters) {
    _pathParameters.addAll(pathParameters);
  }

  /// Removes path parameter by [key].
  void removePathParameter(String key) {
    _pathParameters.remove(key);
  }

  /// Removes all path parameters.
  void removePathParameters() {
    _pathParameters.clear();
  }
}
