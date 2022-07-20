part of minerva_server;

class Pipeline {
  final List<Middleware> _middlewares;

  late final PipelineNode? _first;

  Pipeline(List<Middleware> middlewares) : _middlewares = middlewares {
    _initialize();
  }

  void _initialize() {
    if (_middlewares.isNotEmpty) {
      _first = _createPipelineNode(0);
    }
  }

  PipelineNode? _createPipelineNode(int index) {
    if (index < _middlewares.length) {
      return PipelineNode(_middlewares[index], _createPipelineNode(index + 1));
    } else {
      return null;
    }
  }

  Future<Result> handle(MiddlewareContext context) async {
    if (_first != null) {
      return await _first!.handle(context);
    } else {
      return NotFoundResult();
    }
  }
}
