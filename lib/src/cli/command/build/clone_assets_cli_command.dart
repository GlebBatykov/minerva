part of minerva_cli;

class CloneAssetsCLICommand extends CLICommand<List<FileLog>> {
  final String projectPath;

  final BuildMode mode;

  final AppSetting appSetting;

  final CurrentBuildAppSetting buildAppSetting;

  final List<File> _files = [];

  CloneAssetsCLICommand({
    required this.projectPath,
    required this.mode,
    required this.appSetting,
    required this.buildAppSetting,
  });

  @override
  Future<List<FileLog>> run() async {
    final fileLogs = <FileLog>[];

    late List<String> assets;

    try {
      assets = AppSettingAssetsParser().parse(appSetting, buildAppSetting);
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
    for (final file in _files) {
      final relativePath =
          file.path.substring(projectPath.length, file.path.length);

      final buildFilePath = '$projectPath/build/$mode$relativePath';

      final buildFile = File.fromUri(Uri.file(
        buildFilePath,
        windows: Platform.isWindows,
      ));

      await buildFile.create(
        recursive: true,
      );

      await buildFile.writeAsBytes(await file.readAsBytes());
    }
  }
}
