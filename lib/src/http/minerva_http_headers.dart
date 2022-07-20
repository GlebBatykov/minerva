class MinervaHttpHeaders {
  final bool? chunkedTransferEncoding;

  final bool? persistentConnection;

  final int? contentLength;

  final String? host;

  final int? port;

  final Map<String, String> _headers;

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

  void operator []=(String key, String value) {
    _headers[key] = value;
  }

  String? operator [](String key) {
    return _headers[key];
  }
}
