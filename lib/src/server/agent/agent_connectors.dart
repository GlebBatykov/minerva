part of minerva_server;

/// Contains all connectors that are used to send requests to agents.
class AgentConnectors {
  final List<AgentConnector> _connectors;

  AgentConnectors(List<AgentConnector> connectors) : _connectors = connectors;

  /// If an agent named [name] exists, it returns agent connector.
  ///
  /// If no such agent exists, it returns null.
  AgentConnector? get(String name) {
    for (var connector in _connectors) {
      if (connector.name == name) {
        return connector;
      }
    }

    return null;
  }

  AgentConnector? operator [](String key) {
    return get(key);
  }
}
