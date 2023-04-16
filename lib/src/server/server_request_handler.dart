part of minerva_server;

class ServerRequestHandler {
  final Endpoints _endpoints;

  final ServerContext _context;

  final MiddlewarePipeline _pipeline;

  ServerRequestHandler({
    required Endpoints endpoints,
    required ServerContext context,
    required MiddlewarePipeline pipeline,
  })  : _endpoints = endpoints,
        _context = context,
        _pipeline = pipeline;

  Future<void> handleHttpRequest(HttpRequest request) async {
    final minervaRequest = MinervaRequest(request, _context.converter);

    final context = MiddlewareContext(
      request: minervaRequest,
      httpEndpoints: _endpoints.httpEndpoints,
      webSocketEndpoints: _endpoints.webSocketEndpoints,
      context: _context,
    );

    final result = await _pipeline.handle(context);

    if (minervaRequest.isUpgraded) {
      return;
    }

    final minervaResponse = await _mapResultToResponse(result);

    final response = request.response;

    _setHeaders(response.headers, minervaResponse.headers);

    response.statusCode = minervaResponse.statusCode;

    _writeBody(response, minervaResponse.body);

    await response.close();
  }

  Future<MinervaResponse> _mapResultToResponse(Object? result) async {
    late MinervaResponse response;

    if (result is Result) {
      response = await result.response;
    } else if (result is Map<String, dynamic>) {
      response = await JsonResult(result).response;
    } else {
      response = await OkResult(body: result).response;
    }

    return response;
  }

  void _setHeaders(HttpHeaders headers, MinervaHttpHeaders? minervaHeaders) {
    if (minervaHeaders != null) {
      if (minervaHeaders.contentLength != null) {
        headers.contentLength = minervaHeaders.contentLength!;
      }

      if (minervaHeaders.contentType != null) {
        headers.contentType = minervaHeaders.contentType;
      }

      if (minervaHeaders.host != null) {
        headers.host = minervaHeaders.host!;
      }

      if (minervaHeaders.port != null) {
        headers.port = minervaHeaders.port!;
      }

      if (minervaHeaders.chunkedTransferEncoding != null) {
        headers.chunkedTransferEncoding =
            minervaHeaders.chunkedTransferEncoding!;
      }

      if (minervaHeaders.persistentConnection != null) {
        headers.persistentConnection = minervaHeaders.persistentConnection!;
      }

      for (final entry in minervaHeaders.headers.entries) {
        headers.add(entry.key, entry.value);
      }
    }
  }

  void _writeBody(HttpResponse response, dynamic body) {
    if (body != null) {
      if (body is Uint8List) {
        response.add(body);
      } else {
        response.write(body);
      }
    }
  }
}
