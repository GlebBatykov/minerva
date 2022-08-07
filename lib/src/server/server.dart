part of minerva_server;

class Server {
  final dynamic _address;

  final int _port;

  final SecurityContext? _securityContext;

  final MinervaServerBuilder? _builder;

  late final HttpServer _server;

  final Endpoints _endpoints;

  final List<Api> _apis;

  final MiddlewarePipeline _pipeline;

  late final ServerContext _context;

  late final ServerRequestHandler _handler;

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
        _pipeline = MiddlewarePipeline(middlewares);

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
    await AppSetting.instance.initialize();

    if (_securityContext == null) {
      _server = await HttpServer.bind(_address, _port, shared: true);
    } else {
      _server = await HttpServer.bindSecure(_address, _port, _securityContext!,
          shared: true);
    }

    await logPipeline.initialize(connectors);

    _context = ServerContext(logPipeline, connectors);

    for (var api in _apis) {
      await api.initialize(_context);
    }

    await _pipeline.initialize(_context);

    await _builder?.build(_context);

    _handler = ServerRequestHandler(_endpoints, _context, _pipeline);

    _server.listen(_handler.handleHttpRequest);
  }

  Future<void> dispose() async {
    await _server.close();
  }
}
