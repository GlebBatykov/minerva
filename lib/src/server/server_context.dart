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

  ///
  final Utf8Converter converter = Utf8Converter();

  ServerContext({
    required this.instance,
    required this.logPipeline,
    required this.connectors,
  });
}
