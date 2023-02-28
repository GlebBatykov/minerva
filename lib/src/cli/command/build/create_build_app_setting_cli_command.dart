part of minerva_cli;

class CreateBuildAppSettingCLICommand extends CLICommand<File> {
  final String projectPath;

  final BuildMode mode;

  final FinalBuildAppSetting buildAppSetting;

  CreateBuildAppSettingCLICommand({
    required this.projectPath,
    required this.mode,
    required this.buildAppSetting,
  });

  @override
  Future<File> run() async {
    print('Creating appsetting.json file in the build...');

    final buildAppSettingFile = File.fromUri(Uri.file(
      '$projectPath/build/$mode/appsetting.json',
      windows: Platform.isWindows,
    ));

    await buildAppSettingFile.create(
      recursive: true,
    );

    await buildAppSettingFile
        .writeAsString(jsonEncode(buildAppSetting.toJson()));

    print('Creating appsetting.the json file in the build is completed...');

    return buildAppSettingFile;
  }
}
