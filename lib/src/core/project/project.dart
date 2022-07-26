part of minerva_core;

abstract class Project {
  static String? _projectPath;

  static String get projectPath {
    if (_projectPath == null) {
      var scriptPath = Uri.directory(Platform.script.path);

      _projectPath = scriptPath.pathSegments
          .getRange(0, scriptPath.pathSegments.length - 3)
          .join('/');
    }

    return _projectPath!;
  }
}
