part of minerva_server;

class AgentConnectors {
  final List<AgentConnector> _connectors;

  AgentConnectors(List<AgentConnector> connectors) : _connectors = connectors;

  AgentConnector? operator [](String key) {
    for (var connector in _connectors) {
      if (connector.name == key) {
        return connector;
      }
    }

    return null;
  }
}
