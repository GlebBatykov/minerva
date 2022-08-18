part of minerva_server;

class ServerTaskHandler extends IsolateTaskHandler {
  final int _instance;

  final ServerSetting _setting;

  final Endpoints _endpoints;

  final List<Api> _apis;

  final LogPipeline _logPipeline;

  final AgentConnectors _connectors;

  late final Server _server;

  ServerTaskHandler(int instance, ServerSetting setting, Endpoints endpoints,
      List<Api> apis, LogPipeline logPipeline, AgentConnectors connectors)
      : _instance = instance,
        _setting = setting,
        _endpoints = endpoints,
        _apis = apis,
        _logPipeline = logPipeline,
        _connectors = connectors;

  @override
  Future<void> onStart(IsolateContext context) async {
    _server = await Server.bind(
        _instance, _setting, _endpoints, _apis, _logPipeline, _connectors);
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
