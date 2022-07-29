part of minerva_core;

abstract class HostEnvironment {
  static String? _contentRootPath;

  static String get contentRootPath {
    if (_contentRootPath == null) {
      var executablePath = Uri.parse(Platform.script.path);

      var segments = executablePath.pathSegments;

      segments = segments.where((element) => element.isNotEmpty).toList();

      segments = segments.getRange(0, segments.length - 2).toList();

      _contentRootPath = segments.join('/');

      _contentRootPath = '/$contentRootPath';
    }

    return _contentRootPath!;
  }
}
