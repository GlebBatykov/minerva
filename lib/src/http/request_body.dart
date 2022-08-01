part of minerva_http;

class RequestBody {
  final Stream<Uint8List> _data;

  String? _text;

  Map<String, dynamic>? _json;

  RequestBody(Stream<Uint8List> data) : _data = data;

  Future<String> asText() async {
    _text ??= await utf8.decodeStream(_data);

    return _text!;
  }

  Future<Map<String, dynamic>> asJson() async {
    _json ??= jsonDecode(await utf8.decodeStream(_data));

    return _json!;
  }
}
