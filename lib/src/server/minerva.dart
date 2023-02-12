part of minerva_server;

/// The class that is used to binds, pauses, resumes the server.
class Minerva {
  final Servers _servers = Servers();

  late final Agents _agents;

  late final LogPipeline _logPipeline;

  Minerva._();

  /// Binds server with current [setting].
  static Future<Minerva> bind(
      {required List<String> args,
      required MinervaSettingBuilder settingBuilder}) async {
    if (!AppSetting.instance.isInitialized) {
      await AppSetting.instance.initialize();
    }

    final setting = await settingBuilder.build();

    final minerva = Minerva._();

    final address = _getAddress();

    final middlwares = await setting.middlewaresBuilder.build();

    final serverSetting = ServerSetting(
        address,
        setting.configuration ?? ServerConfiguration(),
        middlwares,
        setting.serverBuilder);

    final agentsData = await setting.agentsBuilder?.build();

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
        final port = AppSetting.instance.port;

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
    _agents = Agents(agentsData);

    await _agents.initialize();

    final loggers = await loggersBuilder.build();

    final connectors = AgentConnectors(_agents.connectors);

    await _servers.initialize(instance, setting, apisBuilder, endpointsBuilder,
        LogPipeline(List.from(loggers)), connectors);

    _logPipeline = LogPipeline(List.from(loggers));

    await _logPipeline.initialize(connectors);

    final host = setting.address.host;

    final port = setting.address.port;

    _logPipeline.info('Server starting in http://$host:$port.');
  }

  /// Pauses server.
  Future<void> pause() async {
    await _agents.pause();

    await _servers.pause();
  }

  /// Resumes server.
  Future<void> resume() async {
    await _agents.resume();

    await _servers.resume();
  }

  /// Disposes server.
  Future<void> dispose() async {
    await _servers.dispose();

    await _logPipeline.dispose(AgentConnectors(_agents.connectors));

    await _agents.dispose();
  }
}
