part of minerva_core;

abstract class HostEnvironment {
  static String? _contentRootPath;

  static String get contentRootPath {
    if (_contentRootPath == null) {
      var executablePath = Uri.parse(Platform.script.path);

      _contentRootPath = executablePath.pathSegments
          .where((element) => element.isNotEmpty)
          .toList()
          .getRange(0, executablePath.pathSegments.length - 3)
          .join('/');

      _contentRootPath = '/$contentRootPath';
    }

    return _contentRootPath!;
  }
}
