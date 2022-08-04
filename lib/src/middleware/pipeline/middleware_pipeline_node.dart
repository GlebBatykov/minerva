part of minerva_middleware;

class MiddlewarePipelineNode {
  final Middleware _current;

  final MiddlewarePipelineNode? _next;

  MiddlewarePipelineNode(Middleware current, MiddlewarePipelineNode? next)
      : _current = current,
        _next = next;

  Future<dynamic> handle(MiddlewareContext context) async {
    return await _current.handle(context, _next);
  }
}
