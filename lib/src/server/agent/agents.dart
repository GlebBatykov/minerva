part of minerva_server;

class Agents {
  final List<AgentData> _agentsData;

  final Map<String, IsolateSupervisor> _supervisors = {};

  final List<AgentConnector> _connectors = [];

  List<AgentConnector> get connectors => List.unmodifiable(_connectors);

  Agents(List<AgentData> agentsData) : _agentsData = agentsData;

  Future<void> initialize() async {
    if (_agentsData.map((e) => e.name).toSet().length != _agentsData.length) {
      throw MinervaBindException(message: 'all agent names must be unique.');
    }

    for (final data in _agentsData) {
      _supervisors[data.name] = IsolateSupervisor();
    }

    await Future.wait(_supervisors.values.map((e) => e.initialize()));

    for (var i = 0; i < _agentsData.length; i++) {
      final data = _agentsData[i];

      IsolateError? error;

      final supervisor = _supervisors[data.name]!;

      final subscription = supervisor.errors.listen((event) {
        error ??= event;
      });

      await supervisor.start(AgentTaskHandler(data.agent, data.data ?? {}));

      subscription.cancel();

      if (error != null) {
        throw MinervaBindException(
            message:
                'an error occurred in the agent with name: ${data.name}.\n\nAgent error:\n\n${error!.error}\n\nAgent stack trace:\n\n${error!.stackTrace}');
      }

      _connectors.add(AgentConnector(data.name, supervisor.isolatePort!));
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
