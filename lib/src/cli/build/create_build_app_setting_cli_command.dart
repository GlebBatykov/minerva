part of minerva_cli;

class CreateBuildAppSettingCLICommand extends CLICommand<void> {
  final String projectPath;

  final String mode;

  final Map<String, dynamic> appSetting;

  final Map<String, dynamic> buildSetting;

  CreateBuildAppSettingCLICommand(
      this.projectPath, this.mode, this.appSetting, this.buildSetting);

  @override
  Future<void> run() async {
    print('Creating appsetting.json file in the build...');

    var buildAppSettingFile =
        File.fromUri(Uri.file('$projectPath/build/$mode/appsetting.json'));

    await buildAppSettingFile.create(recursive: true);

    var buildAppSetting = appSetting;

    buildAppSetting.remove('debug');
    buildAppSetting.remove('release');

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

    await buildAppSettingFile.writeAsString(jsonEncode(buildAppSetting));

    print('Creating appsetting.the json file in the build is completed...');
  }
}
