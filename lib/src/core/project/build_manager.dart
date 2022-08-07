part of minerva_core;

enum BuildType { debug, release }

abstract class BuildManager {
  static bool get isDebug => type == BuildType.debug;

  static bool get isRelease => type == BuildType.release;

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
