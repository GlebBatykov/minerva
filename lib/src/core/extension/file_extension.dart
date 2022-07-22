part of minerva_core;

extension FileExtension on File {
  String get fileExtension => basename(path).split('.').last;

  String? pathStartingFrom(String segment) {
    var segments = path.split('/');

    for (var i = 0; i < segments.length; i++) {
      if (segments[i] == segment) {
        return segments.getRange(i + 1, segment.length).join('/');
      }
    }

    return null;
  }
}
