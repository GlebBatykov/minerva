part of minerva_cli;

class BuildCLICommand extends CLICommand<void> {
  final String projectPath;

  final BuildMode mode;

  final CompileType compileType;

  final File appSettingFile;

  final AppSetting appSetting;

  final CurrentBuildAppSetting buildSetting;

  BuildCLICommand(this.projectPath, this.mode, this.compileType,
      this.appSettingFile, this.appSetting, this.buildSetting);

  @override
  Future<void> run() async {
    final fileLogs = <FileLog>[];

    final futures = <Future>[];

    final buildAppSetting =
        FinalBuildAppSettingBuilder(mode, appSetting, buildSetting).build();

    futures.add(CompileCLICommand(projectPath, mode, compileType)
        .run()
        .then((value) => fileLogs.addAll(value)));

    futures.add(
        CreateBuildAppSettingCLICommand(projectPath, mode, buildAppSetting)
            .run());

    futures.add(
        CloneAssetsCLICommand(projectPath, mode, appSetting, buildSetting)
            .run()
            .then((value) => fileLogs.addAll(value)));

    if (appSetting.buildSetting.testSetting.createAppSetting) {
      futures.add(
          GenerateTestAppSettingCLICommand(projectPath, buildAppSetting).run());
    } else {
      futures.add(DeleteTestAppSettingCLICommand(projectPath).run());
    }

    await Future.wait(futures);

    final appSettingFileLog =
        await FileLogCreater(projectPath).createAppSettingLog(appSettingFile);

    fileLogs.add(appSettingFileLog);

    await _createDetails(fileLogs);
  }

  Future<void> _createDetails(List<FileLog> fileLogs) async {
    final detailsFile =
        File.fromUri(Uri.file('$projectPath/build/$mode/details.json'));

    final details = <String, dynamic>{
      'compile-type': compileType.toString(),
      'files': fileLogs.map((e) => e.toJson()).toList()
    };

    final json = jsonEncode(details);

    await detailsFile.writeAsString(json);
  }
}
