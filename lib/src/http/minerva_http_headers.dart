part of minerva_http;

class MinervaHttpHeaders {
  bool? chunkedTransferEncoding;

  bool? persistentConnection;

  ContentType? contentType;

  int? contentLength;

  String? host;

  int? port;

  final Map<String, Object> _headers;

  Map<String, Object> get headers => Map.unmodifiable(_headers);

  MinervaHttpHeaders({
    this.chunkedTransferEncoding,
    this.persistentConnection,
    this.contentType,
    this.contentLength,
    this.host,
    this.port,
    Map<String, Object>? headers,
  }) : _headers = headers ?? {};

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
