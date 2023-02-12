part of minerva_core;

/// Provides information about the environment in which the project is running.
abstract class HostEnvironment {
  static String? _contentRootPath;

  /// The path to the project folder.
  static String get contentRootPath {
    if (_contentRootPath == null) {
      final executablePath = Uri.parse(Platform.script.path);

      var segments = executablePath.pathSegments;

      segments = segments.where((element) => element.isNotEmpty).toList();

      segments = segments.getRange(0, segments.length - 2).toList();

      _contentRootPath = segments.join('/');

      _contentRootPath = '/$_contentRootPath';
    }

    return _contentRootPath!;
  }
}
