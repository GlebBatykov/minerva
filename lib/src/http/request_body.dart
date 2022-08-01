part of minerva_http;

class RequestBody {
  final Stream<Uint8List> _dataStream;

  List<Uint8List>? _data;

  String? _text;

  Map<String, dynamic>? _json;

  RequestBody(Stream<Uint8List> dataStream) : _dataStream = dataStream;

  Future<List<Uint8List>> get data async {
    _data ??= await _dataStream.toList();

    return _data!;
  }

  Future<String> asText() async {
    _text ??= await utf8.decodeStream(Stream.fromIterable(await data));

    return _text!;
  }

  Future<Map<String, dynamic>> asJson() async {
    _json ??=
        jsonDecode(await utf8.decodeStream(Stream.fromIterable(await data)));

    return _json!;
  }
}
