part of minerva_cli;

class CurrentBuildSettingParser {
  CurrentBuildAppSetting parseCurrent(
    AppSetting appSetting,
    BuildMode mode,
  ) {
    late final BuildAppSetting? setting;

    if (mode == BuildMode.debug) {
      setting = appSetting.debug;
    } else {
      setting = appSetting.release;
    }

    if (setting == null) {
      throw BuildSettingParserException(
        message: 'Setting for $mode mode is not exist in appsetting.json file.',
      );
    }

    if (setting.host == null || setting.port == null) {
      throw BuildSettingParserException(
        message: 'Setting for $mode mode not contains host and port values.',
      );
    }

    return CurrentBuildAppSetting(
      setting.host!,
      setting.port!,
      setting.compileType,
      assets: setting.assets,
      logging: setting.logging,
      values: setting.values,
    );
  }
}
