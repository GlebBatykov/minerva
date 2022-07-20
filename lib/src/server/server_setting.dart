part of minerva_server;

class ServerSetting {
  final dynamic address;

  final int port;

  final SecurityContext? securityContext;

  final List<Middleware> middlewares;

  final ServerBuilder? builder;

  ServerSetting(this.address, this.port,
      {this.securityContext,
      this.middlewares = const [ErrorMiddleware(), EndpointMiddleware()],
      this.builder});
}
