part of minerva_core;

enum BuildType { debug, release }

abstract class BuildManager {
  static BuildType? _type;

  static Future<bool> get isDebug async => (await type) == BuildType.debug;

  static Future<bool> get isRelease async => (await type) == BuildType.release;

  static Future<BuildType> get type async {
    if (_type == null) {
      var appSetting = await AppSetting.instance;

      var buildType = appSetting.buildType;

      if (buildType == null) {
        throw BuildManagerException(
            message: 'Build type info not exist in appsetting.json file.');
      } else {
        if (buildType != 'debug' && buildType != 'release') {
          throw BuildManagerException(
              message: 'Build type is incorrect in appsetting.json file');
        } else {
          _type = BuildType.values
              .firstWhere((element) => element.name == buildType);
        }
      }
    }

    return _type!;
  }
}
