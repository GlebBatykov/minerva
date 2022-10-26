part of minerva_routing;

typedef WebSocketHandler = FutureOr<void> Function(
    ServerContext context, WebSocket socket);

/// Contains information about the websocket endpoint.
class WebSocketEndpoint {
  /// Path of endpoint.
  final String path;

  /// Handler for websocket connection.
  final WebSocketHandler handler;

  WebSocketEndpoint(this.path, this.handler);
}
