part of minerva_cli;

class BuildSettingParser {
  Map<String, dynamic> parseCurrent(
      Map<String, dynamic> appSetting, String mode) {
    var currentBuildSetting = appSetting[mode] as Map<String, dynamic>?;

    if (currentBuildSetting == null) {
      throw BuildSettingParserException(
          message:
              'Setting for $mode mode is not exist in appsetting.json file.');
    }

    if (!currentBuildSetting.containsKey('host') ||
        !currentBuildSetting.containsKey('port')) {
      throw BuildSettingParserException(
          message: 'Setting for $mode mode not contains host and port values.');
    }

    return currentBuildSetting;
  }
}
