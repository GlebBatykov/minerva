part of minerva_server;

class Agents {
  final List<AgentData> _agentsData;

  final Map<String, IsolateSupervisor> _supervisors = {};

  final List<AgentConnector> _connectors = [];

  List<AgentConnector> get connectors => List.unmodifiable(_connectors);

  Agents(List<AgentData> agentsData) : _agentsData = agentsData;

  Future<void> initialize() async {
    for (var data in _agentsData) {
      _supervisors[data.name] = IsolateSupervisor();
    }

    await Future.wait(_supervisors.values.map((e) => e.initialize()));

    for (var i = 0; i < _agentsData.length; i++) {
      var data = _agentsData[i];

      IsolateError? error;

      var supervisor = _supervisors[data.name]!;

      var subscription = supervisor.errors.listen((event) {
        error ??= event;
      });

      await supervisor.start(AgentTaskHandler(data.agent, data.data ?? {}));

      subscription.cancel();

      if (error != null) {
        throw MinervaBindException(
            message:
                'an error occurred in the agent with name: ${data.name}.\n${error!.stackTrace}');
      }
    }
  }

  Future<void> pause() async {
    await Future.wait(_supervisors.values.map((e) => e.pause()));
  }

  Future<void> resume() async {
    await Future.wait(_supervisors.values.map((e) => e.resume()));
  }

  Future<void> dispose() async {
    await Future.wait(_supervisors.values.map((e) => e.dispose()));
  }
}
