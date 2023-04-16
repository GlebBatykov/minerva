part of minerva_server;

/// Contains all connectors that are used to send requests to agents.
class AgentConnectors {
  final List<AgentConnector> _connectors;

  /// All connectors.
  List<AgentConnector> get connectors => List.unmodifiable(_connectors);

  AgentConnectors(List<AgentConnector> connectors) : _connectors = connectors;

  /// If an agent named [name] exists, it returns agent connector.
  ///
  /// If no such agent exists, it returns null.
  AgentConnector? get(String name) {
    for (var i = 0; i < _connectors.length; i++) {
      if (_connectors[i].name == name) {
        return _connectors[i];
      }
    }

    return null;
  }

  AgentConnector? operator [](String key) {
    return get(key);
  }
}
