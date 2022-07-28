part of minerva_server;

class PipelineNode {
  final Middleware _current;

  final PipelineNode? _next;

  PipelineNode(Middleware current, PipelineNode? next)
      : _current = current,
        _next = next;

  Future<dynamic> handle(MiddlewareContext context) async {
    return await _current.handle(context, _next);
  }
}
