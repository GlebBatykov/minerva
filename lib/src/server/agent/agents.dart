part of minerva_server;

class Agents {
  final List<AgentData> _agentsData;

  final Map<String, IsolateSupervisor> _supervisors = {};

  final List<AgentConnector> _connectors = [];

  List<AgentConnector> get connectors => List.unmodifiable(_connectors);

  Agents(List<AgentData> agentsData) : _agentsData = agentsData;

  Future<void> initialize() async {
    await Future.wait(_agentsData.map((e) async {
      var supervisor = await _createAgent(e.agent, e.data);

      _supervisors[e.name] = supervisor;

      _connectors.add(AgentConnector(e.name, supervisor.isolatePort!));
    }));
  }

  Future<IsolateSupervisor> _createAgent(
      Agent agent, Map<String, dynamic>? data) async {
    var supervisor = IsolateSupervisor();

    await supervisor.initialize();

    await supervisor.start(AgentTaskHandler(agent, data ?? {}));

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
