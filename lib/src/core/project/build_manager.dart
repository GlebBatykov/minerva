part of minerva_core;

enum BuildType { debug, release }

/// Provides information about the current build of the project.
abstract class BuildManager {
  /// Checks whether the current build of the project is debug.
  static bool get isDebug => type == BuildType.debug;

  /// Checks whether the current build of the project is release.
  static bool get isRelease => type == BuildType.release;

  /// Provides the type of the current project build.
  static BuildType get type {
    var buildType = AppSetting.instance.buildType;

    if (buildType == null) {
      throw BuildManagerException(
          message: 'Build type info not exist in appsetting.json file.');
    } else {
      if (buildType != 'debug' && buildType != 'release') {
        throw BuildManagerException(
            message: 'Build type is incorrect in appsetting.json file');
      } else {
        return BuildType.values
            .firstWhere((element) => element.name == buildType);
      }
    }
  }
}
