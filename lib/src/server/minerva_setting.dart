part of minerva_server;

class MinervaSetting {
  final SecurityContext? securityContext;

  final MiddlewaresBuilder middlewaresBuilder;

  final EndpointsBuilder endpointsBuilder;

  final ServerBuilder? serverBuilder;

  final Logger? logger;

  final List<AgentData>? agents;

  final int instance;

  MinervaSetting(
      {this.securityContext,
      required this.middlewaresBuilder,
      required this.endpointsBuilder,
      this.serverBuilder,
      this.logger,
      this.agents,
      int? instance})
      : instance = instance ?? Platform.numberOfProcessors;
}
