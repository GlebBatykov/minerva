part of minerva_server;

class ServerContext {
  final ServerStore store = ServerStore();

  final AgentConnectors connectors;

  ServerContext(this.connectors);
}
