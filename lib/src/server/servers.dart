part of minerva_server;

class Servers {
  final List<IsolateSupervisor> _supervisors = [];

  Future<void> initialize(
      int instance,
      ServerSetting setting,
      ApisBuilder? apisBuilder,
      EndpointsBuilder? endpointsBuilder,
      LogPipeline logPipeline,
      AgentConnectors connectors) async {
    var endpoints = Endpoints();

    var apis = await apisBuilder?.call();

    if (apis != null) {
      for (var api in apis) {
        await api.build(endpoints);
      }
    }

    await endpointsBuilder?.call(endpoints);

    _supervisors
        .addAll(List.generate(instance, (index) => IsolateSupervisor()));

    await Future.wait(_supervisors.map((e) => e.initialize().then((value) =>
        e.start(ServerTaskHandler(
            setting, endpoints, apis ?? [], logPipeline, connectors)))));
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
