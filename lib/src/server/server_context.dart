part of minerva_server;

class ServerContext {
  final ServerStore store = ServerStore();

  final ConfigurationManager configuration = ConfigurationManager();

  final Logger logger;

  final AgentConnectors connectors;

  ServerContext(this.logger, this.connectors);
}
