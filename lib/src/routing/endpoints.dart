part of minerva_routing;

/// Contains the endpoints of the current server instance.
class Endpoints {
  final List<Endpoint> _httpEndpoints = [];

  final List<WebSocketEndpoint> _webSocketEndpoints = [];

  /// HTTP endpoints.
  List<Endpoint> get httpEndpoints => List.unmodifiable(_httpEndpoints);

  /// Websocket endpoints.
  List<WebSocketEndpoint> get webSocketEndpoints =>
      List.unmodifiable(_webSocketEndpoints);

  /// Adds endpoint for GET requests.
  void get(String path, EndpointHandler handler,
      {EndpointErrorHandler? errorHandler,
      AuthOptions? authOptions,
      RequestFilter? filter}) {
    _httpEndpoints.add(Endpoint(
        HttpMethod.get, path, handler, errorHandler, authOptions, filter));
  }

  /// Adds endpoint for POST requests.
  void post(String path, EndpointHandler handler,
      {EndpointErrorHandler? errorHandler,
      AuthOptions? authOptions,
      RequestFilter? filter}) {
    _httpEndpoints.add(Endpoint(
        HttpMethod.post, path, handler, errorHandler, authOptions, filter));
  }

  /// Adds endpoint for PUT requests.
  void put(String path, EndpointHandler handler,
      {EndpointErrorHandler? errorHandler,
      AuthOptions? authOptions,
      RequestFilter? filter}) {
    _httpEndpoints.add(Endpoint(
        HttpMethod.put, path, handler, errorHandler, authOptions, filter));
  }

  /// Adds endpoint for HEAD requests.
  void head(String path, EndpointHandler handler,
      {EndpointErrorHandler? errorHandler,
      AuthOptions? authOptions,
      RequestFilter? filter}) {
    _httpEndpoints.add(Endpoint(
        HttpMethod.head, path, handler, errorHandler, authOptions, filter));
  }

  /// Adds endpoint for DELETE requests.
  void delete(String path, EndpointHandler handler,
      {EndpointErrorHandler? errorHandler,
      AuthOptions? authOptions,
      RequestFilter? filter}) {
    _httpEndpoints.add(Endpoint(
        HttpMethod.delete, path, handler, errorHandler, authOptions, filter));
  }

  /// Adds endpoint for PATCH requests.
  void patch(String path, EndpointHandler handler,
      {EndpointErrorHandler? errorHandler,
      AuthOptions? authOptions,
      RequestFilter? filter}) {
    _httpEndpoints.add(Endpoint(
        HttpMethod.patch, path, handler, errorHandler, authOptions, filter));
  }

  /// Adds endpoint for OPTIONS requests.
  void options(String path, EndpointHandler handler,
      {EndpointErrorHandler? errorHandler,
      AuthOptions? authOptions,
      RequestFilter? filter}) {
    _httpEndpoints.add(Endpoint(
        HttpMethod.options, path, handler, errorHandler, authOptions, filter));
  }

  /// Adds endpoint for TRACE requests.
  void trace(String path, EndpointHandler handler,
      {EndpointErrorHandler? errorHandler,
      AuthOptions? authOptions,
      RequestFilter? filter}) {
    _httpEndpoints.add(Endpoint(
        HttpMethod.trace, path, handler, errorHandler, authOptions, filter));
  }

  /// Adds endpoint for websockets.
  void ws(String path, WebSocketHandler handler) {
    _webSocketEndpoints.add(WebSocketEndpoint(path, handler));
  }
}
