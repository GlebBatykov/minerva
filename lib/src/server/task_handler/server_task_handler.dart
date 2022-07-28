part of minerva_server;

class ServerTaskHandler extends IsolateTaskHandler {
  final ServerSetting _setting;

  final Endpoints _endpoints;

  final List<Api> _apis;

  final LogPipeline _logPipeline;

  final AgentConnectors _connectors;

  late final Server _server;

  ServerTaskHandler(ServerSetting setting, Endpoints endpoints, List<Api> apis,
      LogPipeline logPipeline, AgentConnectors connectors)
      : _setting = setting,
        _endpoints = endpoints,
        _apis = apis,
        _logPipeline = logPipeline,
        _connectors = connectors;

  @override
  Future<void> onStart(IsolateContext context) async {
    _server = await Server.bind(
        _setting, _endpoints, _apis, _logPipeline, _connectors);
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
