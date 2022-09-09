part of minerva_server;

class ServerSetting {
  final ServerAddress address;

  final ServerConfiguration configuration;

  final List<Middleware> middlewares;

  final MinervaServerBuilder? builder;

  ServerSetting(
      this.address, this.configuration, this.middlewares, this.builder);
}
