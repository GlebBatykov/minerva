part of minerva_cli;

class BuildCLICommand extends CLICommand<void> {
  final String projectPath;

  final String mode;

  final String compileType;

  final File appSettingFile;

  final Map<String, dynamic> appSetting;

  final Map<String, dynamic> buildSetting;

  BuildCLICommand(this.projectPath, this.mode, this.compileType,
      this.appSettingFile, this.appSetting, this.buildSetting);

  @override
  Future<void> run() async {
    var fileLogs = <FileLog>[];

    var futures = <Future>[];

    var buildAppSetting =
        BuildAppSettingBuilder().build(appSetting, buildSetting);

    futures.add(CompileCLICommand(projectPath, mode, compileType)
        .run()
        .then((value) => fileLogs.addAll(value)));

    futures.add(
        CreateBuildAppSettingCLICommand(projectPath, mode, buildAppSetting)
            .run());

    futures.add(CloneAssetsCLICommand(projectPath, mode, appSetting)
        .run()
        .then((value) => fileLogs.addAll(value)));

    futures.add(
        GenerateTestAppSettingCLICommand(projectPath, buildAppSetting).run());

    await Future.wait(futures);

    var appSettingFileLog = await _getAppSettingFileLog();

    fileLogs.add(appSettingFileLog);

    await _createDetails(fileLogs);
  }

  Future<FileLog> _getAppSettingFileLog() async {
    var appSettingFileStat = await appSettingFile.stat();

    var modificationTime = appSettingFileStat.modified;

    var fileLog = FileLog(
        FileLogType.appsetting, appSettingFile.absolute.path, modificationTime);

    return fileLog;
  }

  Future<void> _createDetails(List<FileLog> fileLogs) async {
    var detailsFile =
        File.fromUri(Uri.file('$projectPath/build/$mode/details.json'));

    var details = <String, dynamic>{
      'compile-type': compileType,
      'files': fileLogs.map((e) => e.toJson()).toList()
    };

    var json = jsonEncode(details);

    await detailsFile.writeAsString(json);
  }
}
