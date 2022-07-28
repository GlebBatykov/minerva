part of minerva_cli;

class CreateBuildAppSettingCLICommand extends CLICommand<File> {
  final String projectPath;

  final String mode;

  final Map<String, dynamic> buildAppSetting;

  CreateBuildAppSettingCLICommand(
      this.projectPath, this.mode, this.buildAppSetting);

  @override
  Future<File> run() async {
    print('Creating appsetting.json file in the build...');

    var buildAppSettingFile = File.fromUri(Uri.file(
        '$projectPath/build/$mode/appsetting.json',
        windows: Platform.isWindows));

    await buildAppSettingFile.create(recursive: true);

    await buildAppSettingFile.writeAsString(jsonEncode(buildAppSetting));

    print('Creating appsetting.the json file in the build is completed...');

    return buildAppSettingFile;
  }
}
