part of minerva_server;

typedef EndpointsBuilder = FutureOr<void> Function(Endpoints endpoints);

class Minerva {
  final Servers _servers = Servers();

  final Agents _agents = Agents();

  Minerva._(int instance, EndpointsBuilder builder);

  static Future<Minerva> bind(
      {int instance = 1,
      required ServerSetting setting,
      required EndpointsBuilder builder,
      List<AgentData>? agents}) async {
    var minerva = Minerva._(instance, builder);

    await minerva._initialize(instance, setting, builder, agents ?? []);

    return minerva;
  }

  Future<void> _initialize(int instance, ServerSetting setting,
      EndpointsBuilder builder, List<AgentData> agentsData) async {
    await _agents.initialize(agentsData);

    var connectors = AgentConnectors(_agents.connectors);

    await _servers.initialize(instance, setting, builder, connectors);
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
