part of minerva_server;

/// Stores data of the current server instance.
class ServerContext {
  /// Number of current server instance.
  final int instance;

  /// Store of current server instance.
  final ServerStore store = ServerStore();

  /// Loggers pipeline of current server instance.
  final LogPipeline logPipeline;

  /// All agent connectors.
  final AgentConnectors connectors;

  ServerContext(this.instance, this.logPipeline, this.connectors);
}
