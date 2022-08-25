part of minerva_server;

class Minerva {
  final Servers _servers = Servers();

  late final Agents _agents;

  late final LogPipeline _logPipeline;

  Minerva._();

  static Future<Minerva> bind(
      {required List<String> args, required MinervaSetting setting}) async {
    if (!AppSetting.instance.isInitialized) {
      await AppSetting.instance.initialize();
    }

    var minerva = Minerva._();

    var address = _getAddress();

    var middlwares = await setting.middlewaresBuilder.build();

    var serverSetting = ServerSetting(
        address, setting.securityContext, middlwares, setting.serverBuilder);

    var agentsData = await setting.agentsBuilder?.build();

    await minerva._initialize(
        setting.instance,
        serverSetting,
        setting.loggersBuilder,
        setting.apisBuilder,
        setting.endpointsBuilder,
        agentsData ?? []);

    return minerva;
  }

  static ServerAddress _getAddress() {
    if (AppSetting.instance.host != null && AppSetting.instance.port != null) {
      try {
        var port = AppSetting.instance.port;

        return ServerAddress(AppSetting.instance.host!, port!);
      } catch (_) {
        throw MinervaBindException(
            message:
                'Invalid host or port values in the appsetting.json file.');
      }
    } else {
      throw MinervaBindException(
          message: 'In the appsetting.json file is missing host or port.');
    }
  }

  Future<void> _initialize(
      int instance,
      ServerSetting setting,
      MinervaLoggersBuilder loggersBuilder,
      MinervaApisBuilder? apisBuilder,
      MinervaEndpointsBuilder? endpointsBuilder,
      List<AgentData> agentsData) async {
    var loggers = await loggersBuilder.build();

    _agents = Agents(agentsData);

    await _agents.initialize();

    var connectors = AgentConnectors(_agents.connectors);

    await _servers.initialize(instance, setting, apisBuilder, endpointsBuilder,
        LogPipeline(List.from(loggers)), connectors);

    _logPipeline = LogPipeline(List.from(loggers));

    await _logPipeline.initialize(connectors);

    var host = setting.address.host;

    var port = setting.address.port;

    _logPipeline.info('Server starting in http://$host:$port.');
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
    await _servers.dispose();

    await _logPipeline.dispose(AgentConnectors(_agents.connectors));

    await _agents.dispose();
  }
}
