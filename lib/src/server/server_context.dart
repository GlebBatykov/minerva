part of minerva_server;

class ServerContext {
  final ServerStore store = ServerStore();

  final ConfigurationManager configuration = ConfigurationManager();

  final LogPipeline logPipeline;

  final AgentConnectors connectors;

  ServerContext(this.logPipeline, this.connectors);
}
