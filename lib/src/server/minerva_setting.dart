part of minerva_server;

/// Server settings. Used during server initialization.
class MinervaSetting {
  /// The number of server instances. Each of the instances will be launched in a separate isolate.
  final int instance;

  /// Additional server settings.
  final ServerConfiguration? configuration;

  /// Used for middlewares configuration.
  final MinervaMiddlewaresBuilder middlewaresBuilder;

  /// Used for endpoints configuration.
  final MinervaEndpointsBuilder? endpointsBuilder;

  /// Used for apis configuration.
  final MinervaApisBuilder? apisBuilder;

  /// Used for server configuration, dependency injection.
  final MinervaServerBuilder? serverBuilder;

  /// Used for loggers configuration.
  final MinervaLoggersBuilder loggersBuilder;

  /// Used for agents configuration.
  final MinervaAgentsBuilder? agentsBuilder;

  MinervaSetting(
      {this.instance = 1,
      this.configuration,
      required this.middlewaresBuilder,
      this.endpointsBuilder,
      this.apisBuilder,
      this.serverBuilder,
      required this.loggersBuilder,
      this.agentsBuilder});
}
