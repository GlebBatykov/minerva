part of minerva_server;

typedef EndpointsBuilder = FutureOr<void> Function(Endpoints endpoints);

typedef MiddlewaresBuilder = FutureOr<List<Middleware>> Function();

class Minerva {
  final Servers _servers = Servers();

  final Agents _agents = Agents();

  final Logger _logger;

  Minerva._(Logger logger) : _logger = logger;

  static Future<Minerva> bind(
      {required List<String> args, required MinervaSetting setting}) async {
    var minerva = Minerva._(setting.logger ?? MinervaLogger());

    var address = await _getAddress();

    var middlwares = await setting.middlewaresBuilder();

    var serverSetting = ServerSetting(
        address, setting.securityContext, middlwares, setting.serverBuilder);

    await minerva._initialize(setting.instance, serverSetting,
        setting.endpointsBuilder, setting.agents ?? []);

    return minerva;
  }

  static Future<ServerAddress> _getAddress() async {
    var appSetting = await AppSetting.instance;

    if (appSetting.host != null && appSetting.port != null) {
      try {
        var port = appSetting.port;

        return ServerAddress(appSetting.host!, port!);
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

  Future<void> _initialize(int instance, ServerSetting setting,
      EndpointsBuilder builder, List<AgentData> agentsData) async {
    await _agents.initialize(agentsData);

    var connectors = AgentConnectors(_agents.connectors);

    await _servers.initialize(instance, setting, builder, _logger, connectors);

    var host = setting.address.host;

    var port = setting.address.port;

    _logger.info('Server starting in http://$host:$port.');
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
