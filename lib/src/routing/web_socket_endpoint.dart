part of minerva_routing;

typedef WebSocketHandler = FutureOr<void> Function(
    ServerContext context, WebSocket socket);

class WebSocketEndpoint {
  final String path;

  final WebSocketHandler handler;

  WebSocketEndpoint(this.path, this.handler);
}
