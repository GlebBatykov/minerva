part of minerva_cli;

class RebuildCLICommand extends CLICommand<void> {
  final String projectPath;

  final String mode;

  final File appSettingFile;

  final Map<String, dynamic> appSetting;

  final Map<String, dynamic> buildSetting;

  final List<FileLog> fileLogs;

  late String _buildDirectory;

  final List<FileLog> _fileLogs = [];

  RebuildCLICommand(this.projectPath, this.mode, this.appSettingFile,
      this.appSetting, this.buildSetting, this.fileLogs);

  @override
  Future<void> run() async {
    var futures = <Future>[
      _recreateAppSetting(),
      _recloneAssets(),
      _recompile(),
      _recreateDetails()
    ];

    await Future.wait(futures);
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

      await CreateBuildAppSettingCLICommand(projectPath, mode, buildAppSetting)
          .run();
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

    late List<String> assets;

    try {
      assets = AppSettingAssetsParser().parse(appSetting);
    } catch (_) {
      assets = [];
    }

    if (assets.isNotEmpty) {
      await _removeUnnecessaryBuildAssets(buildAssetsPaths, assets);
    } else {
      await _clearBuildAssets(buildAssetsPaths);
    }
  }

  List<String> _getBuildAssetsPaths() {
    return fileLogs
        .where((element) => element.type == FileLogType.asset)
        .map((e) => e.path)
        .toList();
  }

  Future<List<String>> _getAssets() async {
    
  }

  Future<void> _removeUnnecessaryBuildAssets(
      List<String> buildAssetsPaths, List<String> assets) async {
    for (var buildAssetPath in buildAssetsPaths) {
      var buildAssetFile = File.fromUri(Uri.file(buildAssetPath));

      if (await buildAssetFile.exists()) {
        var buildAsset = buildAssetPath.substring(_buildDirectory.length);

        if (assets.contains(buildAsset)) {
          var assetFilePath = '$projectPath/$buildAsset';

          var assetFile = File.fromUri(Uri.file(assetFilePath));

          if (assetFile)
        } else {
          await buildAssetFile.delete(recursive: true);
        }
      }
    }
  }

  Future<void> _clearBuildAssets(List<String> assetsPaths) async {
    for (var assetPath in assetsPaths) {
      var file = File.fromUri(Uri.file(assetPath));

      if (await file.exists()) {
        await file.delete(recursive: true);
      }
    }
  }

  Future<void> _recompile() async {
    var buildSourcePaths = _getBuildSourcePaths();
  }

  List<String> _getBuildSourcePaths() {
    return fileLogs
        .where((element) => element.type == FileLogType.source)
        .map((e) => e.path)
        .toList();
  }

  Future<void> _recreateDetails() async {}
}
