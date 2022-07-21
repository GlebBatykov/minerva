part of minerva_server;

class ServerTaskHandler extends IsolateTaskHandler {
  final ServerSetting _setting;

  final Endpoints _endpoints;

  final Logger _logger;

  final AgentConnectors _connectors;

  late final Server _server;

  ServerTaskHandler(ServerSetting setting, Endpoints endpoints, Logger logger,
      AgentConnectors connectors)
      : _setting = setting,
        _endpoints = endpoints,
        _logger = logger,
        _connectors = connectors;

  @override
  Future<void> onStart(IsolateContext context) async {
    _server = await Server.bind(_setting, _endpoints, _logger, _connectors);
  }

  @override
  Future<void> onStop(IsolateContext context) async {
    await _server.dispose();
  }

  @override
  FutureOr<void> onPause(IsolateContext context) {}

  @override
  FutureOr<void> onResume(IsolateContext context) {}
}
