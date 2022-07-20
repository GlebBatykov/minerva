part of minerva_server;

class Agents {
  final Map<String, IsolateSupervisor> _supervisors = {};

  final List<AgentConnector> _connectors = [];

  List<AgentConnector> get connectors => List.unmodifiable(_connectors);

  Future<void> initialize(List<AgentData> agentsData) async {
    await Future.wait(agentsData.map((e) async {
      var supervisor = await _createAgent(e.agent, e.data);

      _supervisors[e.name] = supervisor;

      _connectors.add(AgentConnector(e.name, supervisor.isolatePort!));
    }));
  }

  Future<IsolateSupervisor> _createAgent(
      Agent agent, Map<String, dynamic>? data) async {
    var supervisor = IsolateSupervisor();

    await supervisor.initialize();

    await supervisor.start(AgentTaskHandler(),
        {'agent': agent, 'data': data ?? <String, dynamic>{}});

    return supervisor;
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
