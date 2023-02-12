part of minerva_server;

/// Used to send requests to agents.
class AgentConnector {
  /// Agent's name.
  final String name;

  final SendPort _agentPort;

  AgentConnector(this.name, SendPort agentPort) : _agentPort = agentPort;

  /// Sends a request to the agent.
  ///
  /// A request of this type implies a response to it.
  Future<T> call<T>(String action, {Map<String, dynamic>? data}) async {
    final receivePort = ReceivePort();

    _agentPort.send(AgentCall(action, data ?? {}, receivePort.sendPort));

    final callResult = await receivePort
        .firstWhere((element) => element is AgentCallResult) as AgentCallResult;

    receivePort.close();

    return callResult.result as T;
  }

  /// Sends a request to the agent.
  ///
  /// A request of this type does not imply a response to it.
  void cast(String action, {Map<String, dynamic>? data}) {
    _agentPort.send(AgentCast(action, data ?? {}));
  }
}
