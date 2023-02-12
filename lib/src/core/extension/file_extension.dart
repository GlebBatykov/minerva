part of minerva_core;

extension FileExtension on File {
  String get fileExtension {
    final segments = basename(this.absolute.path).split('.');

    return segments.last;
  }

  /// File name without extension.
  String get fileName {
    final name = basename(this.absolute.path);

    final segments = basename(this.absolute.path).split('.');

    if (name.count('.') > 1) {
      segments.removeLast();

      return segments.join('.');
    } else {
      return segments.first;
    }
  }

  String? pathStartingFrom(String segment) {
    final segments = path.split('/');

    for (var i = 0; i < segments.length; i++) {
      if (segments[i] == segment) {
        return segments.getRange(i + 1, segments.length).join('/');
      }
    }

    return null;
  }

  Future<void> addLine(String line) async {
    var content = await readAsString();

    if (content.isNotEmpty) {
      content = '$content\n$line';
    } else {
      content = line;
    }

    await writeAsString(content);
  }
}
