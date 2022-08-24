part of minerva_cli;

class CloneAssetsCLICommand extends CLICommand<List<FileLog>> {
  final String projectPath;

  final String mode;

  final Map<String, dynamic> appSetting;

  final List<File> _files = [];

  CloneAssetsCLICommand(this.projectPath, this.mode, this.appSetting);

  @override
  Future<List<FileLog>> run() async {
    var fileLogs = <FileLog>[];

    late List<String> assets;

    try {
      assets = AppSettingAssetsParser().parse(appSetting);
    } catch (object) {
      return fileLogs;
    }

    _files.clear();

    _files.addAll(await AssetsFilesParser(projectPath).parseMany(assets));

    await _cloneFiles();

    fileLogs.addAll(await FileLogCreater(projectPath).createAssetsLogs(_files));

    return fileLogs;
  }

  Future<void> _cloneFiles() async {
    for (var file in _files) {
      var relativePath =
          file.path.substring(projectPath.length, file.path.length);

      var buildFilePath = '$projectPath/build/$mode$relativePath';

      var buildFile =
          File.fromUri(Uri.file(buildFilePath, windows: Platform.isWindows));

      await buildFile.create(recursive: true);

      await buildFile.writeAsBytes(await file.readAsBytes());
    }
  }
}
