part of minerva_util;

///
class Utf8Converter {
  const Utf8Converter();

  ///
  String decodeChunks(List<List<int>> chunks) {
    return _joinStrings(chunks.map((e) => _bytesToString(e)).toList());
  }

  ///
  String decodeBytes(List<int> bytes) {
    return _bytesToString(bytes);
  }

  String _bytesToString(List<int> bytes) {
    final buffer = StringBuffer();

    for (var i = 0; i < bytes.length; i++) {
      buffer.writeCharCode(bytes[i]);
    }

    return buffer.toString();
  }

  String _joinStrings(List<String> strings) {
    final buffer = StringBuffer();

    for (var i = 0; i < strings.length; i++) {
      buffer.write(strings[i]);
    }

    return buffer.toString();
  }

  ///
  List<int> encode(String string) {
    final bytes = List<int>.filled(string.length, 0);

    final codeUnits = string.codeUnits;

    for (var i = 0; i < codeUnits.length; i++) {
      bytes[i] = codeUnits[i];
    }

    return bytes;
  }
}
