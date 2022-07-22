part of minerva_server;

typedef EndpointsBuilder = FutureOr<void> Function(Endpoints endpoints);

class Minerva {
  final Servers _servers = Servers();

  final Agents _agents = Agents();

  final Logger _logger;

  Minerva._(Logger logger) : _logger = logger;

  static Future<Minerva> bind(
      {required List<String> args, required MinervaSetting setting}) async {
    var minerva = Minerva._(setting.logger ?? MinervaLogger());

    var address = await _getAddress();

    var serverSetting = ServerSetting(address, setting.securityContext,
        setting.middlewares, setting.serverBuilder);

    await minerva._initialize(setting.instance, serverSetting,
        setting.endpointsBuilder, setting.agents ?? []);

    return minerva;
  }

  static Future<ServerAddress> _getAddress() async {
    var appSetting = await AppSetting.instance;

    var data = appSetting.data;

    if (data.containsKey('host') && data.containsKey('port')) {
      try {
        var port = int.parse(data['port']);

        return ServerAddress(data['address'], port);
      } catch (_) {
        throw MinervaBindException(
            message: 'Invalid port value in the appsetting.json file.');
      }
    } else {
      throw MinervaBindException(
          message: 'In the appsetting file.json is missing host or port.');
    }
  }

  Future<void> _initialize(int instance, ServerSetting setting,
      EndpointsBuilder builder, List<AgentData> agentsData) async {
    await _agents.initialize(agentsData);

    var connectors = AgentConnectors(_agents.connectors);

    await _servers.initialize(instance, setting, builder, _logger, connectors);

    var address = setting.address;

    _logger.info('Server starting in http://${address.host}:${address.port}.');
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
