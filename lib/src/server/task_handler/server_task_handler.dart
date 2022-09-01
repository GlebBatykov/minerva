part of minerva_server;

class ServerTaskHandler extends IsolateTaskHandler {
  final int _instance;

  final ServerSetting _setting;

  final Endpoints _endpoints;

  final Apis _apis;

  final LogPipeline _logPipeline;

  final AgentConnectors _connectors;

  late final Server _server;

  ServerTaskHandler(int instance, ServerSetting setting, Endpoints endpoints,
      Apis apis, LogPipeline logPipeline, AgentConnectors connectors)
      : _instance = instance,
        _setting = setting,
        _endpoints = endpoints,
        _apis = apis,
        _logPipeline = logPipeline,
        _connectors = connectors;

  @override
  Future<void> onStart(IsolateContext context) async {
    try {
      _server = await Server.bind(
          _instance, _setting, _endpoints, _apis, _logPipeline, _connectors);
    } catch (error, stackTrace) {
      context.send(IsolateError(error, stackTrace));
    }
  }

  @override
  Future<void> onStop(IsolateContext context) async {
    await _server.dispose();
  }

  @override
  Future<void> onDispose(IsolateContext context) async {
    await _server.dispose();
  }
}
