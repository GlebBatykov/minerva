part of minerva_server;

class Servers {
  final List<IsolateSupervisor> _supervisors = [];

  Future<void> initialize({
    required int instance,
    required ServerSetting setting,
    required MinervaApisBuilder? apisBuilder,
    required MinervaEndpointsBuilder? endpointsBuilder,
    required LogPipeline logPipeline,
    required AgentConnectors connectors,
  }) async {
    final endpoints = Endpoints();

    final apis = Apis(await apisBuilder?.build() ?? []);

    await apis.build(endpoints);

    await endpointsBuilder?.build(endpoints);

    _supervisors
        .addAll(List.generate(instance, (index) => IsolateSupervisor()));

    await Future.wait(List.generate(
        _supervisors.length, (index) => _supervisors[index].initialize()));

    for (var i = 0; i < _supervisors.length; i++) {
      IsolateError? error;

      final subscription = _supervisors[i].errors.listen((event) {
        error ??= event;
      });

      await _supervisors[i].start(ServerTaskHandler(
        instance: i,
        setting: setting,
        endpoints: endpoints,
        apis: apis,
        logPipeline: logPipeline,
        connectors: connectors,
      ));

      subscription.cancel();

      if (error != null) {
        throw MinervaBindException(
            message:
                'an error occurred in the server instance: $i.\n\nInstance error:\n\n${error!.error}\n\nInstance stack trace:\n\n${error!.stackTrace}');
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
