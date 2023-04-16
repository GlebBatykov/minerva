part of minerva_server;

class ServerSetting {
  final ServerAddress address;

  final ServerConfiguration configuration;

  final List<Middleware> middlewares;

  final MinervaServerBuilder? builder;

  ServerSetting({
    required this.address,
    required this.configuration,
    required this.middlewares,
    required this.builder,
  });
}
