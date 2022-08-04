part of minerva_http;

class RequestBody {
  final Stream<Uint8List> _dataStream;

  final HttpHeaders _headers;

  List<Uint8List>? _data;

  String? _text;

  Map<String, dynamic>? _json;

  FormData? _formData;

  RequestBody(Stream<Uint8List> dataStream, HttpHeaders headers)
      : _dataStream = dataStream,
        _headers = headers;

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

  Future<FormData> asForm() async {
    _formData ??= await FormData.parse(await data, _headers);

    return _formData!;
  }
}
