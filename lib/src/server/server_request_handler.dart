part of minerva_server;

class ServerRequestHandler {
  final Endpoints _endpoints;

  final ServerContext _context;

  final MiddlewarePipeline _pipeline;

  ServerRequestHandler(
      Endpoints endpoints, ServerContext context, MiddlewarePipeline pipeline)
      : _endpoints = endpoints,
        _context = context,
        _pipeline = pipeline;

  Future<void> handleHttpRequest(HttpRequest request) async {
    final minervaRequest = MinervaRequest(request);

    final context = MiddlewareContext(minervaRequest, _endpoints.httpEndpoints,
        _endpoints.webSocketEndpoints, _context);

    final result = await _pipeline.handle(context);

    late MinervaResponse minervaResponse;

    if (result is Result) {
      minervaResponse = await result.response;
    } else if (result is Map<String, dynamic>) {
      minervaResponse = await JsonResult(result).response;
    } else {
      minervaResponse = await OkResult(body: result).response;
    }

    if (minervaRequest.isUpgraded) {
      return;
    }

    final response = request.response;

    _setHeaders(response.headers, minervaResponse.headers);

    response.statusCode = minervaResponse.statusCode;

    _writeBody(response, minervaResponse.body);

    await response.close();
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
