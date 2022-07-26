part of minerva_http;

class MinervaHttpHeaders {
  final bool? chunkedTransferEncoding;

  final bool? persistentConnection;

  final ContentType? contentType;

  final int? contentLength;

  final String? host;

  final int? port;

  final Map<String, Object> _headers;

  Map<String, Object> get headers => Map.unmodifiable(_headers);

  MinervaHttpHeaders(
      {this.chunkedTransferEncoding,
      this.persistentConnection,
      this.contentType,
      this.contentLength,
      this.host,
      this.port,
      Map<String, Object>? headers})
      : _headers = headers ?? {};

  void addEntries(Iterable<MapEntry<String, Object>> newEntries) {
    _headers.addEntries(newEntries);
  }

  void addAll(Map<String, Object> other) {
    _headers.addAll(other);
  }

  void operator []=(String key, Object value) {
    _headers[key] = value;
  }

  Object? operator [](String key) {
    return _headers[key];
  }
}
