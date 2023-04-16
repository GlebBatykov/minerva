part of minerva_http;

class RequestBody {
  final Stream<Uint8List> _dataStream;

  final HttpHeaders _headers;

  final Utf8Converter _converter;

  List<Uint8List>? _data;

  String? _text;

  dynamic _json;

  FormData? _formData;

  bool _isJsonDecoded = false;

  RequestBody({
    required Stream<Uint8List> dataStream,
    required HttpHeaders headers,
    required Utf8Converter converter,
  })  : _dataStream = dataStream,
        _headers = headers,
        _converter = converter;

  Future<List<Uint8List>> get data async {
    _data ??= await _dataStream.toList();

    return _data!;
  }

  Future<String> asText() async {
    _text ??= _converter.decodeChunks(await data);

    return _text!;
  }

  Future<dynamic> asJson() async {
    if (_isJsonDecoded) {
      return _json;
    }

    _json = jsonDecode(_converter.decodeChunks(await data));

    _isJsonDecoded = true;

    return _json;
  }

  Future<FormData> asForm() async {
    _formData ??= await FormData.parse(await data, _headers);

    return _formData!;
  }
}
