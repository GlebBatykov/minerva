part of minerva_http;

class MinervaResponse {
  final int statusCode;

  final dynamic body;

  final MinervaHttpHeaders? headers;

  MinervaResponse({
    required this.statusCode,
    this.body,
    this.headers,
  });
}
