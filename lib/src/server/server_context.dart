part of minerva_server;

class ServerContext {
  final ServerStore store = ServerStore();

  final LogPipeline logPipeline;

  final AgentConnectors connectors;

  ServerContext(this.logPipeline, this.connectors);
}
