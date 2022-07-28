part of minerva_core;

abstract class Project {
  static String? _projectPath;

  static String get projectPath {
    if (_projectPath == null) {
      var executablePath = Uri.parse(Platform.script.path);

      _projectPath = executablePath.pathSegments
          .where((element) => element.isNotEmpty)
          .toList()
          .getRange(0, executablePath.pathSegments.length - 3)
          .join('/');
    }

    return _projectPath!;
  }
}
