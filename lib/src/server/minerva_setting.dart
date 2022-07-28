part of minerva_server;

class MinervaSetting {
  final int instance;

  final SecurityContext? securityContext;

  final MiddlewaresBuilder middlewaresBuilder;

  final EndpointsBuilder? endpointsBuilder;

  final ApisBuilder? apisBuilder;

  final ServerBuilder? serverBuilder;

  final LoggersBuilder loggersBuilder;

  final AgentsBuilder? agentsBuilder;

  MinervaSetting(
      {this.instance = 1,
      this.securityContext,
      required this.middlewaresBuilder,
      this.endpointsBuilder,
      this.apisBuilder,
      this.serverBuilder,
      required this.loggersBuilder,
      this.agentsBuilder});
}
