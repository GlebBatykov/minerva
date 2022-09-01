part of minerva_server;

class Servers {
  final List<IsolateSupervisor> _supervisors = [];

  Future<void> initialize(
      int instance,
      ServerSetting setting,
      MinervaApisBuilder? apisBuilder,
      MinervaEndpointsBuilder? endpointsBuilder,
      LogPipeline logPipeline,
      AgentConnectors connectors) async {
    var endpoints = Endpoints();

    var apis = Apis(await apisBuilder?.build() ?? []);

    await apis.build(endpoints);

    await endpointsBuilder?.build(endpoints);

    _supervisors
        .addAll(List.generate(instance, (index) => IsolateSupervisor()));

    await Future.wait(List.generate(
        _supervisors.length, (index) => _supervisors[index].initialize()));

    for (var i = 0; i < _supervisors.length; i++) {
      IsolateError? error;

      var subscription = _supervisors[i].errors.listen((event) {
        error ??= event;
      });

      await _supervisors[i].start(ServerTaskHandler(
          i, setting, endpoints, apis, logPipeline, connectors));

      subscription.cancel();

      if (error != null) {
        throw MinervaBindException(
            message:
                'an error occurred in the server instance: $i.\n${error!.stackTrace}');
      }
    }
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
