part of minerva_cli;

class BuildCLICommand extends CLICommand<void> {
  final String projectPath;

  final BuildMode mode;

  final CompileType compileType;

  final File appSettingFile;

  final AppSetting appSetting;

  final CurrentBuildAppSetting buildSetting;

  BuildCLICommand({
    required this.projectPath,
    required this.mode,
    required this.compileType,
    required this.appSettingFile,
    required this.appSetting,
    required this.buildSetting,
  });

  @override
  Future<void> run() async {
    final fileLogs = <FileLog>[];

    final futures = <Future>[];

    final buildAppSetting = FinalBuildAppSettingBuilder(
      mode: mode,
      appSetting: appSetting,
      buildSetting: buildSetting,
    ).build();

    futures.add(CompileCLICommand(
      projectPath: projectPath,
      mode: mode,
      compileType: compileType,
    ).run().then((v) => fileLogs.addAll(v)));

    futures.add(CreateBuildAppSettingCLICommand(
      projectPath: projectPath,
      mode: mode,
      buildAppSetting: buildAppSetting,
    ).run());

    futures.add(CloneAssetsCLICommand(
      projectPath: projectPath,
      mode: mode,
      appSetting: appSetting,
      buildAppSetting: buildSetting,
    ).run().then((v) => fileLogs.addAll(v)));

    final createAppSetting =
        appSetting.buildSetting.testSetting.createAppSetting;

    if (createAppSetting) {
      futures.add(GenerateTestAppSettingCLICommand(
        projectPath,
        buildAppSetting,
      ).run());
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
