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

  Server._({
    required dynamic address,
    required int port,
    required MinervaServerBuilder? builder,
    required ServerConfiguration configuration,
    required Endpoints endpoints,
    required Apis apis,
    required List<Middleware> middlewares,
  })  : _address = address,
        _port = port,
        _builder = builder,
        _configuration = configuration,
        _endpoints = endpoints,
        _apis = apis,
        _pipeline = MiddlewarePipeline(middlewares);

  static Future<Server> bind({
    required int instance,
    required ServerSetting setting,
    required Endpoints endpoints,
    required Apis apis,
    required LogPipeline logPipeline,
    required AgentConnectors connectors,
  }) async {
    final address = setting.address;

    final server = Server._(
      address: address.host,
      port: address.port,
      builder: setting.builder,
      configuration: setting.configuration,
      endpoints: endpoints,
      apis: apis,
      middlewares: setting.middlewares,
    );

    await server._initialize(
      instance: instance,
      logPipeline: logPipeline,
      connectors: connectors,
    );

    return server;
  }

  Future<void> _initialize({
    required int instance,
    required LogPipeline logPipeline,
    required AgentConnectors connectors,
  }) async {
    await AppSetting.instance.initialize();

    await _bindServer();

    await logPipeline.initialize(connectors);

    _context = ServerContext(
      instance: instance,
      logPipeline: logPipeline,
      connectors: connectors,
    );

    await _apis.initialize(_context);

    await _pipeline.initialize(_context);

    await _builder?.build(_context);

    _handler = ServerRequestHandler(
      endpoints: _endpoints,
      context: _context,
      pipeline: _pipeline,
    );

    _server.listen(_handler.handleHttpRequest);
  }

  Future<void> _bindServer() async {
    if (_configuration is SecureServerConfiguration) {
      final configuration = _configuration as SecureServerConfiguration;

      _server = await HttpServer.bindSecure(
        _address,
        _port,
        configuration.securityContext,
        shared: true,
        backlog: configuration.backlog,
        v6Only: configuration.v6Only,
        requestClientCertificate: configuration.requestClientCertificate,
      );
    } else {
      _server = await HttpServer.bind(
        _address,
        _port,
        shared: true,
        backlog: _configuration.backlog,
        v6Only: _configuration.v6Only,
      );
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
