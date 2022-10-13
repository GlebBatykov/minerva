part of minerva_http;

class FormData {
  final Map<String, FormDataValue> _data;

  Map<String, FormDataValue> get data => Map.unmodifiable(_data);

  Iterable<MapEntry<String, FormDataString>> get fields => data.entries
      .where((element) => element.value is FormDataString)
      .cast<MapEntry<String, FormDataString>>();

  Iterable<MapEntry<String, FormDataFile>> get files => data.entries
      .where((element) => element.value is FormDataFile)
      .cast<MapEntry<String, FormDataFile>>();

  FormData._(Map<String, FormDataValue> data) : _data = data;

  static Future<FormData> parse(
      List<Uint8List> bytes, HttpHeaders headers) async {
    var data = <String, FormDataValue>{};

    var boundary = headers.contentType!.parameters['boundary'];

    var transformer = MimeMultipartTransformer(boundary!);

    var bytesStream = Stream.fromIterable(bytes.map((e) => e.toList()));

    var parts = await transformer.bind(bytesStream).toList();

    for (var part in parts) {
      var values = part.headers['content-disposition']!.split(';');

      String? name, filename;

      for (var value in values) {
        if (value.contains('filename') && filename == null) {
          filename = value.substring(value.indexOf('=') + 2, value.length - 1);
        } else if (value.contains('name') && name == null) {
          name = value.substring(value.indexOf('=') + 2, value.length - 1);
        }
      }

      if (filename != null) {
        data[name!] = FormDataFile(
            filename, Uint8List.fromList(await (part.cast<List<int>>()).first));
      } else {
        data[name!] = FormDataString(await utf8.decodeStream(
            Stream.fromIterable([await part.cast<List<int>>().first])));
      }
    }

    return FormData._(data);
  }

  FormDataValue? operator [](String key) {
    return _data[key];
  }
}
