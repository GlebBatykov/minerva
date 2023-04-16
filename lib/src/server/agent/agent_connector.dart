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
  Future<T> call<T>(
    String action, {
    Map<String, Object?>? data,
  }) async {
    final receivePort = ReceivePort();

    final callAction = AgentCall(
      action: action,
      data: data ?? {},
      feedbackPort: receivePort.sendPort,
    );

    _agentPort.send(callAction);

    final callResult = await receivePort.firstWhere((e) => e is AgentCallResult)
        as AgentCallResult;

    receivePort.close();

    return callResult.result as T;
  }

  /// Sends a request to the agent.
  ///
  /// A request of this type does not imply a response to it.
  void cast(
    String action, {
    Map<String, Object?>? data,
  }) {
    _agentPort.send(AgentCast(action, data ?? {}));
  }
}
