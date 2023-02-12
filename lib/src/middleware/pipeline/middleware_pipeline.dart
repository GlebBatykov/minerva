part of minerva_middleware;

class MiddlewarePipeline {
  final List<Middleware> _middlewares;

  late final MiddlewarePipelineNode? _first;

  MiddlewarePipeline(List<Middleware> middlewares)
      : _middlewares = middlewares {
    _initialize();
  }

  Future<void> initialize(ServerContext context) async {
    await Future.wait(_middlewares
        .map((e) => Future(() async => await e.initialize(context))));
  }

  void _initialize() {
    if (_middlewares.isNotEmpty) {
      _first = _createPipelineNode(0);
    }
  }

  MiddlewarePipelineNode? _createPipelineNode(int index) {
    if (index < _middlewares.length) {
      return MiddlewarePipelineNode(
          _middlewares[index], _createPipelineNode(index + 1));
    } else {
      return null;
    }
  }

  Future<dynamic> handle(MiddlewareContext context) async {
    if (_first != null) {
      return await _first!.handle(context);
    } else {
      return NotFoundResult();
    }
  }

  Future<void> dispose(ServerContext context) async {
    for (final middleware in _middlewares) {
      await middleware.dispose(context);
    }
  }
}
