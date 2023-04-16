part of minerva_http;

class FormData {
  final Map<String, FormDataValue> _data;

  Map<String, FormDataValue> get data => Map.unmodifiable(_data);

  Iterable<MapEntry<String, FormDataString>> get fields => data.entries
      .where((e) => e.value is FormDataString)
      .cast<MapEntry<String, FormDataString>>();

  Iterable<MapEntry<String, FormDataFile>> get files => data.entries
      .where((e) => e.value is FormDataFile)
      .cast<MapEntry<String, FormDataFile>>();

  FormData._(Map<String, FormDataValue> data) : _data = data;

  static Future<FormData> parse(
    List<Uint8List> bytes,
    HttpHeaders headers,
  ) async {
    final data = <String, FormDataValue>{};

    final boundary = headers.contentType!.parameters['boundary'];

    final transformer = MimeMultipartTransformer(boundary!);

    final bytesStream = Stream.fromIterable(bytes.map((e) => e.toList()));

    final transformStream = transformer.bind(bytesStream);

    await for (final part in transformStream) {
      final values = part.headers['content-disposition']!.split(';');

      String? name, filename;

      for (var i = 0; i < values.length; i++) {
        final value = values[i];

        if (value.contains('filename') && filename == null) {
          filename = value.substring(
            value.indexOf('=') + 2,
            value.length - 1,
          );
        } else if (value.contains('name') && name == null) {
          name = value.substring(
            value.indexOf('=') + 2,
            value.length - 1,
          );
        }
      }

      if (filename != null) {
        data[name!] =
            FormDataFile(filename, Uint8List.fromList(await part.first));
      } else {
        data[name!] = FormDataString(utf8.decode(await part.first));
      }
    }

    return FormData._(data);
  }

  FormDataValue? operator [](String key) {
    return _data[key];
  }
}
