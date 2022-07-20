part of minerva_server;

class Servers {
  final List<IsolateSupervisor> _supervisors = [];

  Future<void> initialize(int instance, ServerSetting setting,
      EndpointsBuilder builder, AgentConnectors connectors) async {
    var endpoints = Endpoints();

    await builder(endpoints);

    _supervisors
        .addAll(List.generate(instance, (index) => IsolateSupervisor()));

    await Future.wait(_supervisors.map((e) => e.initialize().then((value) =>
        e.start(ServerTaskHandler(setting, endpoints, connectors)))));
  }

  Future<void> pause() async {
    await Future.wait(_supervisors.map((e) => e.pause()));
  }

  Future<void> resume() async {
    await Future.wait(_supervisors.map((e) => e.resume()));
  }

  Future<void> dispose() async {
    await Future.wait(_supervisors.map((e) => e.dispose()));
  }
}
