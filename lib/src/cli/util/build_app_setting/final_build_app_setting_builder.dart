part of minerva_cli;

class FinalBuildAppSettingBuilder {
  final BuildMode mode;

  final AppSetting appSetting;

  final CurrentBuildAppSetting buildSetting;

  FinalBuildAppSettingBuilder(this.mode, this.appSetting, this.buildSetting);

  FinalBuildAppSetting build() {
    final host = buildSetting.host;

    final port = buildSetting.port;

    final buildType = BuildType.fromName(mode.toString());

    final values = appSetting.values ?? {};

    if (buildSetting.values != null) {
      values.addAll(buildSetting.values!);
    }

    final logging = appSetting.logging ?? {};

    if (buildSetting.logging != null) {
      logging.addAll(buildSetting.logging!);
    }

    return FinalBuildAppSetting(host, port, buildType,
        values: values.isNotEmpty ? values : null,
        logging: logging.isNotEmpty ? logging : null);
  }
}
