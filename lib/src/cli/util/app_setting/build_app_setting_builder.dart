part of minerva_cli;

class BuildAppSettingBuilder {
  final String mode;

  final Map<String, dynamic> appSetting;

  final Map<String, dynamic> buildSetting;

  BuildAppSettingBuilder(this.mode, this.appSetting, this.buildSetting);

  Map<String, dynamic> build() {
    var buildAppSetting = Map<String, dynamic>.from(appSetting);

    buildAppSetting.remove('debug');
    buildAppSetting.remove('release');
    buildAppSetting.remove('assets');

    buildAppSetting['host'] = buildSetting['host'];
    buildAppSetting['port'] = buildSetting['port'];

    buildAppSetting['build-type'] = mode;

    if (buildSetting.containsKey('values')) {
      var buildValues = buildSetting['values'];

      if (buildAppSetting.containsKey('values')) {
        var values = (buildAppSetting['values'] as Map<String, dynamic>);

        values.addAll(buildValues);

        buildAppSetting['values'] = values;
      } else {
        buildAppSetting['values'] = buildValues;
      }
    }

    return buildAppSetting;
  }
}
