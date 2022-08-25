part of minerva_server;

class Apis {
  final List<Api> _apis;

  Apis(List<Api> apis) : _apis = apis;

  Future<void> initialize(ServerContext context) async {
    for (var api in _apis) {
      await api.initialize(context);
    }
  }

  Future<void> build(Endpoints endpoints) async {
    for (var api in _apis) {
      await api.build(endpoints);
    }
  }

  Future<void> dispose(ServerContext context) async {
    for (var api in _apis) {
      await api.dispose(context);
    }
  }
}
