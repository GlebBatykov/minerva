part of minerva_cli;

class CreateBuildAppSettingCLICommand extends CLICommand<void> {
  final String projectPath;

  final String mode;

  final Map<String, dynamic> buildAppSetting;

  CreateBuildAppSettingCLICommand(
      this.projectPath, this.mode, this.buildAppSetting);

  @override
  Future<void> run() async {
    print('Creating appsetting.json file in the build...');

    var buildAppSettingFile =
        File.fromUri(Uri.file('$projectPath/build/$mode/appsetting.json'));

    await buildAppSettingFile.create(recursive: true);

    await buildAppSettingFile.writeAsString(jsonEncode(buildAppSetting));

    print('Creating appsetting.the json file in the build is completed...');
  }
}
