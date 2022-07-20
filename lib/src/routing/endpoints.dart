part of minerva_routing;

class Endpoints {
  final List<Endpoint> _httpEndpoints = [];

  final List<WebSocketEndpoint> _webSocketEndpoints = [];

  List<Endpoint> get httpEndpoints => List.unmodifiable(_httpEndpoints);

  List<WebSocketEndpoint> get webSocketEndpoints =>
      List.unmodifiable(_webSocketEndpoints);

  void get(String path, EndpointHandler handler,
      {EndpointErrorHandler? errorHandler, List<String>? roles}) {
    _httpEndpoints.add(
        Endpoint(HttpMethod.get, path, handler, errorHandler, roles ?? []));
  }

  void post(String path, EndpointHandler handler,
      {EndpointErrorHandler? errorHandler, List<String>? roles}) {
    _httpEndpoints.add(
        Endpoint(HttpMethod.post, path, handler, errorHandler, roles ?? []));
  }

  void put(String path, EndpointHandler handler,
      {EndpointErrorHandler? errorHandler, List<String>? roles}) {
    _httpEndpoints.add(
        Endpoint(HttpMethod.put, path, handler, errorHandler, roles ?? []));
  }

  void head(String path, EndpointHandler handler,
      {EndpointErrorHandler? errorHandler, List<String>? roles}) {
    _httpEndpoints.add(
        Endpoint(HttpMethod.head, path, handler, errorHandler, roles ?? []));
  }

  void delete(String path, EndpointHandler handler,
      {EndpointErrorHandler? errorHandler, List<String>? roles}) {
    _httpEndpoints.add(
        Endpoint(HttpMethod.delete, path, handler, errorHandler, roles ?? []));
  }

  void patch(String path, EndpointHandler handler,
      {EndpointErrorHandler? errorHandler, List<String>? roles}) {
    _httpEndpoints.add(
        Endpoint(HttpMethod.patch, path, handler, errorHandler, roles ?? []));
  }

  void options(String path, EndpointHandler handler,
      {EndpointErrorHandler? errorHandler, List<String>? roles}) {
    _httpEndpoints.add(
        Endpoint(HttpMethod.options, path, handler, errorHandler, roles ?? []));
  }

  void trace(String path, EndpointHandler handler,
      {EndpointErrorHandler? errorHandler, List<String>? roles}) {
    _httpEndpoints.add(
        Endpoint(HttpMethod.trace, path, handler, errorHandler, roles ?? []));
  }

  void ws(String path, WebSocketHandler handler) {
    _webSocketEndpoints.add(WebSocketEndpoint(path, handler));
  }
}
