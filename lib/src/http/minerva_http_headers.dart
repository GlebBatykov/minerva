part of minerva_http;

class MinervaHttpHeaders {
  final bool? chunkedTransferEncoding;

  final bool? persistentConnection;

  final int? contentLength;

  final String? host;

  final int? port;

  final Map<String, Object> _headers;

  Map<String, String> get headers => Map.unmodifiable(_headers);

  MinervaHttpHeaders(
      {this.chunkedTransferEncoding,
      this.persistentConnection,
      this.contentLength,
      this.host,
      this.port,
      Map<String, String>? headers})
      : _headers = headers ?? {};

  void addEntries(Iterable<MapEntry<String, String>> newEntries) {
    _headers.addEntries(newEntries);
  }

  void addAll(Map<String, String> other) {
    _headers.addAll(other);
  }

  void operator []=(String key, Object value) {
    _headers[key] = value;
  }

  Object? operator [](String key) {
    return _headers[key];
  }
}
