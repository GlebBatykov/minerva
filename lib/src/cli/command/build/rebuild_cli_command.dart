part of minerva_cli;

class RebuildCLICommand extends CLICommand<void> {
  final String projectPath;

  final String mode;

  final String compileType;

  final File appSettingFile;

  final Map<String, dynamic> appSetting;

  final Map<String, dynamic> buildSetting;

  final List<FileLog> fileLogs;

  late String _buildDirectory;

  RebuildCLICommand(this.projectPath, this.mode, this.compileType,
      this.appSettingFile, this.appSetting, this.buildSetting, this.fileLogs);

  @override
  Future<void> run() async {
    var futures = <Future>[
      _recreateAppSetting(),
      _recloneAssets(),
      _recompile()
    ];

    await Future.wait(futures);

    await _recreateDetails(fileLogs);
  }

  Future<void> _recreateAppSetting() async {
    var buildAppSettingPath = '$projectPath/build/$mode/appsetting.json';

    var buildAppSettingFile = File.fromUri(Uri.file(buildAppSettingPath));

    var isNeedRecreate = await _isNeedRecreateAppSetting(buildAppSettingFile);

    if (isNeedRecreate) {
      var buildAppSetting =
          BuildAppSettingBuilder().build(appSetting, buildSetting);

      if (await buildAppSettingFile.exists()) {
        await buildAppSettingFile.delete();
      }

      await buildAppSettingFile.create(recursive: true);

      await buildAppSettingFile.writeAsString(jsonEncode(buildAppSetting));

      fileLogs.removeWhere((element) => element.type == FileLogType.appsetting);

      fileLogs.add(await FileLogCreater(projectPath)
          .createAppSettingLog(buildAppSettingFile));
    }
  }

  Future<bool> _isNeedRecreateAppSetting(File buildAppSettingFile) async {
    if (!await buildAppSettingFile.exists()) {
      return true;
    }

    var buildAppSettingFileStat = await buildAppSettingFile.stat();

    var appSettingFileStat = await appSettingFile.stat();

    if (appSettingFileStat.modified.isAfter(buildAppSettingFileStat.modified)) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> _recloneAssets() async {
    _buildDirectory = '$projectPath/build/$mode';

    var buildAssetsPaths = _getBuildAssetsPaths();

    var buildAssetsFiles = buildAssetsPaths
        .map((e) => File.fromUri(Uri.file(e, windows: Platform.isWindows)))
        .toList();

    late List<String> assets;

    try {
      assets = AppSettingAssetsParser().parse(appSetting);
    } catch (_) {
      assets = [];
    }

    var assetsFiles = await AssetsFilesParser(projectPath).parse(assets);

    if (assets.isNotEmpty) {
      await _removeUnnecessaryBuildAssets(buildAssetsFiles, assetsFiles);
    } else {
      await _clearBuildAssets(buildAssetsFiles);
    }

    await _cloneAssets(assetsFiles);
  }

  List<String> _getBuildAssetsPaths() {
    return fileLogs
        .where((element) => element.type == FileLogType.asset)
        .map((e) => absolute(_buildDirectory, e.path))
        .toList();
  }

  Future<void> _removeUnnecessaryBuildAssets(
      List<File> buildAssetsFiles, List<File> assetsFiles) async {
    for (var buildAssetFile in buildAssetsFiles) {
      if (await buildAssetFile.exists()) {
        var buildAssetRelativePath =
            relative(buildAssetFile.path, from: _buildDirectory);

        var filtred = assetsFiles.where((element) =>
            relative(element.path, from: projectPath) ==
            buildAssetRelativePath);

        if (filtred.isEmpty) {
          _deleteFile(buildAssetFile);

          fileLogs.removeWhere((element) =>
              element.path ==
              relative(buildAssetFile.path, from: _buildDirectory));
        }
      }
    }
  }

  Future<bool> _isOutdated(File buildAssetFile, File assetFile) async {
    var buildAssetFileStat = await buildAssetFile.stat();

    var assetFileStat = await assetFile.stat();

    return assetFileStat.modified.isAfter(buildAssetFileStat.modified);
  }

  Future<void> _clearBuildAssets(List<File> assetsFiles) async {
    for (var assetFile in assetsFiles) {
      await _deleteFile(assetFile);
    }
  }

  Future<void> _deleteFile(File file) async {
    if (await file.exists()) {
      await file.delete(recursive: true);
    }
  }

  Future<void> _cloneAssets(List<File> files) async {
    for (var file in files) {
      var relativePath =
          file.path.substring(projectPath.length, file.path.length);

      var buildFilePath = '$projectPath/build/$mode$relativePath';

      var buildFile =
          File.fromUri(Uri.file(buildFilePath, windows: Platform.isWindows));

      if (!await buildFile.exists()) {
        await _writeFile(buildFile, file);
      } else if (await _isOutdated(buildFile, file)) {
        await _writeFile(buildFile, file);
      }
    }
  }

  Future<void> _writeFile(File buildFile, File file) async {
    fileLogs.removeWhere((element) =>
        element.path == relative(buildFile.path, from: _buildDirectory));

    await buildFile.writeAsBytes(await file.readAsBytes());

    var fileLog = await FileLogCreater(projectPath).createAssetLog(file);

    fileLogs.add(fileLog);
  }

  Future<void> _recompile() async {
    var sourceFilesLogs = _getSourceLogs();

    var isNeedRecompile = await _isNeedRecompile(sourceFilesLogs);

    if (isNeedRecompile) {
      var rebuildSourceFileLog =
          await CompileCLICommand(projectPath, mode, compileType).run();

      fileLogs.removeWhere((element) => element.type == FileLogType.source);

      fileLogs.addAll(rebuildSourceFileLog);
    }
  }

  Future<bool> _isNeedRecompile(List<FileLog> sourceFilesLogs) async {
    for (var sourceLog in sourceFilesLogs) {
      var sourceFile = File.fromUri(Uri.file(
          absolute(projectPath, sourceLog.path),
          windows: Platform.isWindows));

      if (!await sourceFile.exists()) {
        return true;
      }

      var sourceFileStat = await sourceFile.stat();

      if (sourceFileStat.modified.isAfter(sourceLog.modificationTime)) {
        return true;
      }
    }

    return false;
  }

  List<FileLog> _getSourceLogs() {
    return fileLogs
        .where((element) => element.type == FileLogType.source)
        .toList();
  }

  Future<void> _recreateDetails(List<FileLog> fileLogs) async {
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
