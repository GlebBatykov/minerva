part of minerva_middleware;

/// Node of middleware pipeline.
class MiddlewarePipelineNode {
  final Middleware _current;

  final MiddlewarePipelineNode? _next;

  MiddlewarePipelineNode(Middleware current, MiddlewarePipelineNode? next)
      : _current = current,
        _next = next;

  /// Handle request.
  Future<dynamic> handle(MiddlewareContext context) async {
    return await _current.handle(context, _next);
  }
}
