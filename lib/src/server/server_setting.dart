part of minerva_server;

class ServerSetting {
  final ServerAddress address;

  final SecurityContext? securityContext;

  final List<Middleware> middlewares;

  final ServerBuilder? builder;

  ServerSetting(
      this.address, this.securityContext, this.middlewares, this.builder);
}
