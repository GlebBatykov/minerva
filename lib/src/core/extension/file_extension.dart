part of minerva_core;

extension FileExtension on File {
  String get fileExtension {
    var segments = basename(this.absolute.path).split('.');

    return segments.last;
  }

  /// File name without extension.
  String get fileName {
    var name = basename(this.absolute.path);

    var segments = basename(this.absolute.path).split('.');

    if (name.count('.') > 1) {
      segments.removeLast();

      return segments.join('.');
    } else {
      return segments.first;
    }
  }

  String? pathStartingFrom(String segment) {
    var segments = path.split('/');

    for (var i = 0; i < segments.length; i++) {
      if (segments[i] == segment) {
        return segments.getRange(i + 1, segments.length).join('/');
      }
    }

    return null;
  }
}
