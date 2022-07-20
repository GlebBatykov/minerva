part of minerva_server;

typedef ServerBuilder = FutureOr<void> Function(ServerContext context);

class Server {
  final dynamic _address;

  final int _port;

  final SecurityContext? _securityContext;

  final ServerBuilder? _builder;

  late final HttpServer _server;

  final Endpoints _endpoints;

  final Pipeline _pipeline;

  late final ServerContext _context;

  Server._(
      dynamic address,
      int port,
      ServerBuilder? builder,
      SecurityContext? securityContext,
      Endpoints endpoints,
      List<Middleware> middlewares)
      : _address = address,
        _port = port,
        _builder = builder,
        _securityContext = securityContext,
        _endpoints = endpoints,
        _pipeline = Pipeline(middlewares);

  static Future<Server> bind(ServerSetting setting, Endpoints endpoints,
      AgentConnectors connectors) async {
    var server = Server._(setting.address, setting.port, setting.builder,
        setting.securityContext, endpoints, setting.middlewares);

    await server._initialize(connectors);

    return server;
  }

  Future<void> _initialize(AgentConnectors connectors) async {
    if (_securityContext == null) {
      _server = await HttpServer.bind(_address, _port, shared: true);
    } else {
      _server = await HttpServer.bindSecure(_address, _port, _securityContext!,
          shared: true);
    }

    _context = ServerContext(connectors);

    await _builder?.call(_context);

    _server.listen(_handleHttpRequest);
  }

  void _handleHttpRequest(HttpRequest request) async {
    if (!WebSocketTransformer.isUpgradeRequest(request)) {
      await _handleRequest(request);
    } else {
      await _handleWebSocket(request);
    }
  }

  Future<void> _handleRequest(HttpRequest request) async {
    var minervaRequest = MinervaRequest(request);

    var context =
        MiddlewareContext(minervaRequest, _endpoints.httpEndpoints, _context);

    var result = await _pipeline.handle(context);

    late MinervaResponse minervaResponse;

    if (result is Result) {
      minervaResponse = await result.response;
    } else {
      minervaResponse = await OkResult(body: result).response;
    }

    var response = request.response;

    _setHeaders(response.headers, minervaResponse.headers);

    response.statusCode = minervaResponse.statusCode;

    if (minervaResponse.body != null) {
      response.write(minervaResponse.body);
    }

    await response.close();
  }

  void _setHeaders(HttpHeaders headers, MinervaHttpHeaders? minervaHeaders) {
    if (minervaHeaders != null) {
      if (minervaHeaders.contentLength != null) {
        headers.contentLength = minervaHeaders.contentLength!;
      }

      if (minervaHeaders.host != null) {
        headers.host = minervaHeaders.host!;
      }

      if (minervaHeaders.port != null) {
        headers.port = minervaHeaders.port!;
      }

      if (minervaHeaders.chunkedTransferEncoding != null) {
        headers.chunkedTransferEncoding =
            minervaHeaders.chunkedTransferEncoding!;
      }

      if (minervaHeaders.persistentConnection != null) {
        headers.persistentConnection = minervaHeaders.persistentConnection!;
      }

      for (var entry in minervaHeaders.headers.entries) {
        headers.add(entry.key, entry.value);
      }
    }
  }

  Future<void> _handleWebSocket(HttpRequest request) async {
    var endpoints = _endpoints.webSocketEndpoints
        .where((element) => element.path == request.uri.path)
        .toList();

    if (endpoints.isNotEmpty) {
      var socket = await WebSocketTransformer.upgrade(request);

      await endpoints.first.handler(_context, socket);
    } else {
      var response = request.response;

      response.statusCode = 404;

      await response.close();
    }
  }

  Future<void> dispose() async {
    await _server.close();
  }
}
