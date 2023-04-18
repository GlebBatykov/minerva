part of minerva_util;

///
class Utf8Converter {
  const Utf8Converter();

  ///
  String decodeChunks(List<List<int>> chunks) {
    final buffer = StringBuffer();

    for (var i = 0; i < chunks.length; i++) {
      for (var j = 0; j < chunks[i].length; j++) {
        buffer.writeCharCode(chunks[i][j]);
      }
    }

    return buffer.toString();
  }

  ///
  String decodeBytes(List<int> bytes) {
    final buffer = StringBuffer();

    for (var i = 0; i < bytes.length; i++) {
      buffer.writeCharCode(bytes[i]);
    }

    return buffer.toString();
  }

  ///
  List<int> encode(
    String string, {
    bool growable = false,
  }) {
    final bytes = List<int>.filled(
      string.length,
      0,
      growable: growable,
    );

    final codeUnits = string.codeUnits;

    for (var i = 0; i < codeUnits.length; i++) {
      bytes[i] = codeUnits[i];
    }

    return bytes;
  }
}
