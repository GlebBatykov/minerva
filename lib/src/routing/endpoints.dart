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
  void get(
    String path,
    EndpointHandler handler, {
    EndpointErrorHandler? errorHandler,
    AuthOptions? authOptions,
    RequestFilter? filter,
  }) {
    final endpoint = Endpoint(
      method: HttpMethod.get,
      path: path,
      handler: handler,
      errorHandler: errorHandler,
      authOptions: authOptions,
      filter: filter,
    );

    _httpEndpoints.add(endpoint);
  }

  /// Adds endpoint for POST requests.
  void post(
    String path,
    EndpointHandler handler, {
    EndpointErrorHandler? errorHandler,
    AuthOptions? authOptions,
    RequestFilter? filter,
  }) {
    final endpoint = Endpoint(
      method: HttpMethod.post,
      path: path,
      handler: handler,
      errorHandler: errorHandler,
      authOptions: authOptions,
      filter: filter,
    );

    _httpEndpoints.add(endpoint);
  }

  /// Adds endpoint for PUT requests.
  void put(
    String path,
    EndpointHandler handler, {
    EndpointErrorHandler? errorHandler,
    AuthOptions? authOptions,
    RequestFilter? filter,
  }) {
    final endpoint = Endpoint(
      method: HttpMethod.put,
      path: path,
      handler: handler,
      errorHandler: errorHandler,
      authOptions: authOptions,
      filter: filter,
    );

    _httpEndpoints.add(endpoint);
  }

  /// Adds endpoint for HEAD requests.
  void head(
    String path,
    EndpointHandler handler, {
    EndpointErrorHandler? errorHandler,
    AuthOptions? authOptions,
    RequestFilter? filter,
  }) {
    final endpoint = Endpoint(
      method: HttpMethod.head,
      path: path,
      handler: handler,
      errorHandler: errorHandler,
      authOptions: authOptions,
      filter: filter,
    );

    _httpEndpoints.add(endpoint);
  }

  /// Adds endpoint for DELETE requests.
  void delete(
    String path,
    EndpointHandler handler, {
    EndpointErrorHandler? errorHandler,
    AuthOptions? authOptions,
    RequestFilter? filter,
  }) {
    final endpoint = Endpoint(
      method: HttpMethod.delete,
      path: path,
      handler: handler,
      errorHandler: errorHandler,
      authOptions: authOptions,
      filter: filter,
    );

    _httpEndpoints.add(endpoint);
  }

  /// Adds endpoint for PATCH requests.
  void patch(
    String path,
    EndpointHandler handler, {
    EndpointErrorHandler? errorHandler,
    AuthOptions? authOptions,
    RequestFilter? filter,
  }) {
    final endpoint = Endpoint(
      method: HttpMethod.patch,
      path: path,
      handler: handler,
      errorHandler: errorHandler,
      authOptions: authOptions,
      filter: filter,
    );

    _httpEndpoints.add(endpoint);
  }

  /// Adds endpoint for OPTIONS requests.
  void options(
    String path,
    EndpointHandler handler, {
    EndpointErrorHandler? errorHandler,
    AuthOptions? authOptions,
    RequestFilter? filter,
  }) {
    final endpoint = Endpoint(
      method: HttpMethod.options,
      path: path,
      handler: handler,
      errorHandler: errorHandler,
      authOptions: authOptions,
      filter: filter,
    );

    _httpEndpoints.add(endpoint);
  }

  /// Adds endpoint for TRACE requests.
  void trace(
    String path,
    EndpointHandler handler, {
    EndpointErrorHandler? errorHandler,
    AuthOptions? authOptions,
    RequestFilter? filter,
  }) {
    final endpoint = Endpoint(
      method: HttpMethod.trace,
      path: path,
      handler: handler,
      errorHandler: errorHandler,
      authOptions: authOptions,
      filter: filter,
    );

    _httpEndpoints.add(endpoint);
  }

  /// Adds endpoint for websockets.
  void ws(String path, WebSocketHandler handler) {
    _webSocketEndpoints.add(WebSocketEndpoint(path, handler));
  }
}
