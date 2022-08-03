part of minerva_http;

class FormDataFile extends FormDataValue {
  final String name;

  final Uint8List bytes;

  FormDataFile(this.name, this.bytes);
}
