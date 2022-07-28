part of minerva_server;

class Server {
  final dynamic _address;

  final int _port;

  final SecurityContext? _securityContext;

  final MinervaServerBuilder? _builder;

  late final HttpServer _server;

  final Endpoints _endpoints;

  final List<Api> _apis;

  final Pipeline _pipeline;

  late final ServerContext _context;

  Server._(
      dynamic address,
      int port,
      MinervaServerBuilder? builder,
      SecurityContext? securityContext,
      Endpoints endpoints,
      List<Api> apis,
      List<Middleware> middlewares)
      : _address = address,
        _port = port,
        _builder = builder,
        _securityContext = securityContext,
        _endpoints = endpoints,
        _apis = apis,
        _pipeline = Pipeline(middlewares);

  static Future<Server> bind(
      ServerSetting setting,
      Endpoints endpoints,
      List<Api> apis,
      LogPipeline logPipeline,
      AgentConnectors connectors) async {
    var address = setting.address;

    var server = Server._(address.host, address.port, setting.builder,
        setting.securityContext, endpoints, apis, setting.middlewares);

    await server._initialize(logPipeline, connectors);

    return server;
  }

  Future<void> _initialize(
      LogPipeline logPipeline, AgentConnectors connectors) async {
    if (_securityContext == null) {
      _server = await HttpServer.bind(_address, _port, shared: true);
    } else {
      _server = await HttpServer.bindSecure(_address, _port, _securityContext!,
          shared: true);
    }

    await logPipeline.initialize();

    _context = ServerContext(logPipeline, connectors);

    for (var api in _apis) {
      await api.initialize(_context);
    }

    await _pipeline.initialize(_context);

    await _builder?.build(_context);

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

    _writeBody(response, minervaResponse.body);

    await response.close();
  }

  void _setHeaders(HttpHeaders headers, MinervaHttpHeaders? minervaHeaders) {
    if (minervaHeaders != null) {
      if (minervaHeaders.contentLength != null) {
        headers.contentLength = minervaHeaders.contentLength!;
      }

      if (minervaHeaders.contentType != null) {
        headers.contentType = minervaHeaders.contentType;
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

  void _writeBody(HttpResponse response, dynamic body) {
    if (body != null) {
      if (body is Uint8List) {
        response.add(body);
      } else {
        response.write(body);
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
