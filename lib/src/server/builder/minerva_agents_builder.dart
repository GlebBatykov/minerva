part of minerva_server;

/// Used to configure the agents on the server.
abstract class MinervaAgentsBuilder {
  FutureOr<List<AgentData>> build();
}
