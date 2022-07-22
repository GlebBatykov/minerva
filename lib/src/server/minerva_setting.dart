part of minerva_server;

class MinervaSetting {
  final SecurityContext? securityContext;

  final List<Middleware> middlewares;

  final EndpointsBuilder endpointsBuilder;

  final ServerBuilder? serverBuilder;

  final Logger? logger;

  final List<AgentData>? agents;

  final int instance;

  MinervaSetting(
      {this.securityContext,
      this.middlewares = const [ErrorMiddleware(), EndpointMiddleware()],
      required this.endpointsBuilder,
      this.serverBuilder,
      this.logger,
      this.agents,
      int? instance})
      : instance = instance ?? Platform.numberOfProcessors;
}
