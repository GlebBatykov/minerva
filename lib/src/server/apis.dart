part of minerva_server;

class Apis {
  final List<Api> _apis;

  Apis(List<Api> apis) : _apis = apis;

  Future<void> initialize(ServerContext context) async {
    for (var i = 0; i < _apis.length; i++) {
      await _apis[i].initialize(context);
    }
  }

  Future<void> build(Endpoints endpoints) async {
    for (var i = 0; i < _apis.length; i++) {
      await _apis[i].build(endpoints);
    }
  }

  Future<void> dispose(ServerContext context) async {
    for (var i = 0; i < _apis.length; i++) {
      await _apis[i].dispose(context);
    }
  }
}
