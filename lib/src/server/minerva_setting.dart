part of minerva_server;

class MinervaSetting {
  final int instance;

  final SecurityContext? securityContext;

  final MinervaMiddlewaresBuilder middlewaresBuilder;

  final MinervaEndpointsBuilder? endpointsBuilder;

  final MinervaApisBuilder? apisBuilder;

  final MinervaServerBuilder? serverBuilder;

  final MinervaLoggersBuilder loggersBuilder;

  final MinervaAgentsBuilder? agentsBuilder;

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
