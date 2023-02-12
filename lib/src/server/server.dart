part of minerva_server;

class Server {
  final dynamic _address;

  final int _port;

  final ServerConfiguration _configuration;

  final MinervaServerBuilder? _builder;

  late final HttpServer _server;

  final Endpoints _endpoints;

  final Apis _apis;

  final MiddlewarePipeline _pipeline;

  late final ServerContext _context;

  late final ServerRequestHandler _handler;

  Server._(
      dynamic address,
      int port,
      MinervaServerBuilder? builder,
      ServerConfiguration configuration,
      Endpoints endpoints,
      Apis apis,
      List<Middleware> middlewares)
      : _address = address,
        _port = port,
        _builder = builder,
        _configuration = configuration,
        _endpoints = endpoints,
        _apis = apis,
        _pipeline = MiddlewarePipeline(middlewares);

  static Future<Server> bind(
      int instance,
      ServerSetting setting,
      Endpoints endpoints,
      Apis apis,
      LogPipeline logPipeline,
      AgentConnectors connectors) async {
    final address = setting.address;

    final server = Server._(address.host, address.port, setting.builder,
        setting.configuration, endpoints, apis, setting.middlewares);

    await server._initialize(instance, logPipeline, connectors);

    return server;
  }

  Future<void> _initialize(
      int instance, LogPipeline logPipeline, AgentConnectors connectors) async {
    await AppSetting.instance.initialize();

    await _bindServer();

    await logPipeline.initialize(connectors);

    _context = ServerContext(instance, logPipeline, connectors);

    await _apis.initialize(_context);

    await _pipeline.initialize(_context);

    await _builder?.build(_context);

    _handler = ServerRequestHandler(_endpoints, _context, _pipeline);

    _server.listen(_handler.handleHttpRequest);
  }

  Future<void> _bindServer() async {
    if (_configuration is SecureServerConfiguration) {
      final configuration = _configuration as SecureServerConfiguration;

      _server = await HttpServer.bindSecure(
          _address, _port, configuration.securityContext,
          shared: true,
          backlog: configuration.backlog,
          v6Only: configuration.v6Only,
          requestClientCertificate: configuration.requestClientCertificate);
    } else {
      _server = await HttpServer.bind(_address, _port,
          shared: true,
          backlog: _configuration.backlog,
          v6Only: _configuration.v6Only);
    }

    final sessionTimeout = _configuration.sessionTimeout;

    if (sessionTimeout != null) {
      _server.sessionTimeout = sessionTimeout;
    }
  }

  Future<void> dispose() async {
    await _server.close();

    await _apis.dispose(_context);

    await _pipeline.dispose(_context);

    await _context.logPipeline.dispose(_context.connectors);
  }
}
