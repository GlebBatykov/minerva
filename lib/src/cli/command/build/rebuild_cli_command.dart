part of minerva_cli;

class RebuildCLICommand extends CLICommand<void> {
  final String projectPath;

  final BuildMode mode;

  final CompileType compileType;

  final File appSettingFile;

  final AppSetting appSetting;

  final CurrentBuildAppSetting buildSetting;

  final CompileType buildCompileType;

  final List<FileLog> fileLogs;

  late String _buildDirectory;

  RebuildCLICommand({
    required this.projectPath,
    required this.mode,
    required this.compileType,
    required this.appSettingFile,
    required this.appSetting,
    required this.buildSetting,
    required this.buildCompileType,
    required this.fileLogs,
  });

  @override
  Future<void> run() async {
    final futures = <Future>[
      _recreateAppSetting(),
      _recloneAssets(),
      _recompile(),
    ];

    await Future.wait(futures);

    await _recreateDetails(fileLogs);
  }

  Future<void> _recreateAppSetting() async {
    final buildAppSettingPath = '$projectPath/build/$mode/appsetting.json';

    final buildAppSettingFile = File.fromUri(Uri.file(buildAppSettingPath));

    final isNeedRecreate = await _isNeedRecreateAppSetting(buildAppSettingFile);

    if (isNeedRecreate) {
      final buildAppSetting = FinalBuildAppSettingBuilder(
        mode: mode,
        appSetting: appSetting,
        buildSetting: buildSetting,
      ).build();

      final futures = <Future>[];

      futures.add(_createAppSetting(
        buildAppSettingFile,
        buildAppSetting,
      ));

      final createAppSetting =
          appSetting.buildSetting.testSetting.createAppSetting;

      if (createAppSetting) {
        futures.add(
            GenerateTestAppSettingCLICommand(projectPath, buildAppSetting)
                .run());
      } else {
        futures.add(DeleteTestAppSettingCLICommand(projectPath).run());
      }

      await Future.wait(futures);
    }
  }

  Future<void> _createAppSetting(
    File buildAppSettingFile,
    FinalBuildAppSetting buildAppSetting,
  ) async {
    if (await buildAppSettingFile.exists()) {
      await buildAppSettingFile.delete();
    }

    await buildAppSettingFile.create(recursive: true);

    await buildAppSettingFile
        .writeAsString(jsonEncode(buildAppSetting.toJson()));

    fileLogs.removeWhere((e) => e.type == FileLogType.appsetting);

    fileLogs.add(await FileLogCreater(projectPath)
        .createAppSettingLog(buildAppSettingFile));
  }

  Future<bool> _isNeedRecreateAppSetting(File buildAppSettingFile) async {
    if (!await buildAppSettingFile.exists()) {
      return true;
    }

    final buildAppSettingFileStat = await buildAppSettingFile.stat();

    final appSettingFileStat = await appSettingFile.stat();

    if (appSettingFileStat.modified.isAfter(buildAppSettingFileStat.modified)) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> _recloneAssets() async {
    _buildDirectory = '$projectPath/build/$mode';

    final buildAssetsPaths = _getBuildAssetsPaths();

    final buildAssetsFiles = buildAssetsPaths
        .map((e) => File.fromUri(Uri.file(
              e,
              windows: Platform.isWindows,
            )))
        .toList();

    late List<String> assets;

    try {
      assets = AppSettingAssetsParser().parse(appSetting, buildSetting);
    } catch (_) {
      assets = [];
    }

    final assetsFiles = await AssetsFilesParser(projectPath).parseMany(assets);

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
    List<File> buildAssetsFiles,
    List<File> assetsFiles,
  ) async {
    for (final buildAssetFile in buildAssetsFiles) {
      if (await buildAssetFile.exists()) {
        final buildAssetRelativePath =
            relative(buildAssetFile.path, from: _buildDirectory);

        final filtred = assetsFiles.where((element) =>
            relative(element.path, from: projectPath) ==
            buildAssetRelativePath);

        if (filtred.isEmpty) {
          _deleteFile(buildAssetFile);

          fileLogs.removeWhere((e) =>
              e.path ==
              relative(
                buildAssetFile.path,
                from: _buildDirectory,
              ));
        }
      }
    }
  }

  Future<bool> _isOutdated(
    File buildAssetFile,
    File assetFile,
  ) async {
    final buildAssetFileStat = await buildAssetFile.stat();

    final assetFileStat = await assetFile.stat();

    return assetFileStat.modified.isAfter(buildAssetFileStat.modified);
  }

  Future<void> _clearBuildAssets(List<File> assetsFiles) async {
    for (final assetFile in assetsFiles) {
      await _deleteFile(assetFile);
    }
  }

  Future<void> _deleteFile(File file) async {
    if (await file.exists()) {
      await file.delete(recursive: true);
    }
  }

  Future<void> _cloneAssets(List<File> files) async {
    for (final file in files) {
      final relativePath =
          file.path.substring(projectPath.length, file.path.length);

      final buildFilePath = '$projectPath/build/$mode$relativePath';

      final buildFile = File.fromUri(Uri.file(
        buildFilePath,
        windows: Platform.isWindows,
      ));

      if (!await buildFile.exists()) {
        await _writeFile(buildFile, file);
      } else if (await _isOutdated(buildFile, file)) {
        await _writeFile(buildFile, file);
      }
    }
  }

  Future<void> _writeFile(
    File buildFile,
    File file,
  ) async {
    if (!await buildFile.exists()) {
      await buildFile.create(
        recursive: true,
      );
    }

    fileLogs.removeWhere((e) =>
        e.path ==
        relative(
          buildFile.path,
          from: _buildDirectory,
        ));

    await buildFile.writeAsBytes(await file.readAsBytes());

    final fileLog = await FileLogCreater(projectPath).createAssetLog(file);

    fileLogs.add(fileLog);
  }

  Future<void> _recompile() async {
    final sourceFilesLogs = _getSourceLogs();

    final isNeedRecompile = await _isNeedRecompile(sourceFilesLogs);

    if (isNeedRecompile) {
      final rebuildSourceFileLog = await CompileCLICommand(
        projectPath: projectPath,
        mode: mode,
        compileType: compileType,
      ).run();

      fileLogs.removeWhere((e) => e.type == FileLogType.source);

      fileLogs.addAll(rebuildSourceFileLog);
    } else {
      print('Recompile is not needed...');
    }
  }

  Future<bool> _isNeedRecompile(List<FileLog> sourceFilesLogs) async {
    if (compileType != buildCompileType) {
      return true;
    }

    late String executableFilePath;

    if (compileType == CompileType.aot) {
      executableFilePath = Platform.isWindows
          ? '$projectPath/build/$mode/bin/main.exe'
          : '$projectPath/build/$mode/bin/main';
    } else {
      executableFilePath = '$projectPath/build/$mode/bin/main.dill';
    }

    final executableFile = File.fromUri(Uri.file(executableFilePath));

    if (!await executableFile.exists()) {
      return true;
    }

    for (final sourceLog in sourceFilesLogs) {
      final sourceFile = File.fromUri(Uri.file(
        absolute(projectPath, sourceLog.path),
        windows: Platform.isWindows,
      ));

      if (!await sourceFile.exists()) {
        return true;
      }

      final sourceFileStat = await sourceFile.stat();

      if (sourceFileStat.modified.isAfter(sourceLog.modificationTime)) {
        return true;
      }
    }

    return false;
  }

  List<FileLog> _getSourceLogs() {
    return fileLogs.where((e) => e.type == FileLogType.source).toList();
  }

  Future<void> _recreateDetails(List<FileLog> fileLogs) async {
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
