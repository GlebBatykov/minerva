part of minerva_server;

typedef EndpointsBuilder = FutureOr<void> Function(Endpoints endpoints);

class Minerva {
  final Servers _servers = Servers();

  final Agents _agents = Agents();

  final Logger _logger;

  Minerva._(int instance, EndpointsBuilder builder, Logger logger)
      : _logger = logger;

  static Future<Minerva> bind(
      {int instance = 1,
      required ServerSetting setting,
      required EndpointsBuilder builder,
      Logger? logger,
      List<AgentData>? agents}) async {
    var minerva = Minerva._(instance, builder,
        logger ?? MinervaLogger('[&time] [&level] &message'));

    await minerva._initialize(instance, setting, builder, agents ?? []);

    return minerva;
  }

  Future<void> _initialize(int instance, ServerSetting setting,
      EndpointsBuilder builder, List<AgentData> agentsData) async {
    await _agents.initialize(agentsData);

    var connectors = AgentConnectors(_agents.connectors);

    await _servers.initialize(instance, setting, builder, _logger, connectors);

    _logger
        .info('Server starting in http://${setting.address}:${setting.port}.');
  }

  Future<void> pause() async {
    await _agents.pause();

    await _servers.pause();
  }

  Future<void> resume() async {
    await _agents.resume();

    await _servers.resume();
  }

  Future<void> dispose() async {
    await _agents.dispose();

    await _servers.dispose();
  }
}
