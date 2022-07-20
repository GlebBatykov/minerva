part of minerva_server;

class AgentConnector {
  final String name;

  final SendPort _agentPort;

  AgentConnector(this.name, SendPort agentPort) : _agentPort = agentPort;

  Future<T> call<T>(String action, {Map<String, dynamic>? data}) async {
    var receivePort = ReceivePort();

    _agentPort.send(AgentCall(action, data ?? {}, receivePort.sendPort));

    var callResult = await receivePort
        .firstWhere((element) => element is AgentCallResult) as AgentCallResult;

    receivePort.close();

    return callResult.result as T;
  }

  void cast(String action, {Map<String, dynamic>? data}) {
    _agentPort.send(AgentCast(action, data ?? {}));
  }
}
