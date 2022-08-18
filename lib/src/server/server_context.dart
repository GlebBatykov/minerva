part of minerva_server;

class ServerContext {
  final int instance;

  final ServerStore store = ServerStore();

  final LogPipeline logPipeline;

  final AgentConnectors connectors;

  ServerContext(this.instance, this.logPipeline, this.connectors);
}
