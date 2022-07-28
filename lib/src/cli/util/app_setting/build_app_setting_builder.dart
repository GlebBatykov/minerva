part of minerva_cli;

class BuildAppSettingBuilder {
  Map<String, dynamic> build(
      Map<String, dynamic> appSetting, Map<String, dynamic> buildSetting) {
    var buildAppSetting = appSetting;

    buildAppSetting.remove('debug');
    buildAppSetting.remove('release');
    buildAppSetting.remove('assets');

    buildAppSetting['host'] = buildSetting['host'];
    buildAppSetting['port'] = buildSetting['port'];

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
