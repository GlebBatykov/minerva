part of minerva_cli;

class BuildCommand extends Command {
  @override
  String get name => 'build';

  @override
  String get description => 'Build project.';

  @override
  String get usage => '''
    -d  --directory points to the project directory.
    -m  --mode      sets the project build mode. Possible values: debug (default), release.
  ''';

  late String _directoryPath;

  late String _mode;

  late String _compileType;

  late File _appSettingFile;

  late Map<String, dynamic> _appSetting;

  final Map<String, dynamic> _details = {};

  BuildCommand() {
    argParser.addOption('directory',
        abbr: 'd', defaultsTo: Directory.current.path);
    argParser.addOption('mode',
        abbr: 'm', defaultsTo: 'debug', allowed: ['debug', 'release']);
  }

  @override
  Future<void> run() async {
    _directoryPath = Directory.fromUri(Uri.directory(argResults!['directory'],
            windows: Platform.isWindows))
        .absolute
        .path;

    _mode = argResults!['mode'];

    late AppSettingParseResult appSettingParseResult;

    try {
      appSettingParseResult = await AppSettingParcer().parse(_directoryPath);
    } on AppSettingParserException catch (object) {
      usageException(object.message);
    }

    _appSetting = appSettingParseResult.data;

    _appSettingFile = appSettingParseResult.file;

    var currentBuildSetting =
        BuildSettingParser().parseCurrent(_appSetting, _mode);

    _compileType = currentBuildSetting['compile-type'] ?? 'JIT';

    var isNeedScratchBuild = await _isNeedBuildFromScratch(_compileType);

    if (isNeedScratchBuild) {
      await _clearBuild();

      await _build(currentBuildSetting, _compileType);
    } else {
      await _rebuild(currentBuildSetting);
    }
  }

  Future<bool> _isNeedBuildFromScratch(String compileType) async {
    var detailsFile = File.fromUri(Uri.file(
        '$_directoryPath/build/$_mode/details.json',
        windows: Platform.isWindows));

    var detailsFileExists = await detailsFile.exists();

    if (!detailsFileExists) {
      return true;
    }

    _details.clear();

    try {
      _details.addAll(jsonDecode(await detailsFile.readAsString()));

      if (!_details.containsKey('compile-type') ||
          !_details.containsKey('files')) {
        return true;
      }
    } catch (_) {
      return true;
    }

    return false;
  }

  Future<void> _clearBuild() async {
    var buildDirectoryPath = '$_directoryPath/build/$_mode';

    var buildDirectory = Directory.fromUri(Uri.directory(
        '$_directoryPath/build/$_mode',
        windows: Platform.isWindows));

    if (await buildDirectory.exists()) {
      print('The $_mode build folder is being cleared...');

      await ClearDirectoryCLICommand(buildDirectoryPath).run();

      print('The $_mode build folder has been cleared...');
    }
  }

  Future<void> _build(
      Map<String, dynamic> buildSetting, String compileType) async {
    try {
      await BuildCLICommand(_directoryPath, _mode, compileType, _appSettingFile,
              _appSetting, buildSetting)
          .run();
    } on CLICommandException catch (object) {
      usageException(object.message);
    } catch (object) {
      usageException(object.toString());
    }
  }

  Future<void> _rebuild(Map<String, dynamic> buildSetting) async {
    try {
      var fileLogs =
          (_details['files'] as List).map((e) => FileLog.fromJson(e)).toList();

      await RebuildCLICommand(_directoryPath, _mode, _compileType,
              _appSettingFile, _appSetting, buildSetting, fileLogs)
          .run();
    } on CLICommandException catch (object) {
      usageException(object.message);
    } catch (object) {
      usageException(object.toString());
    }
  }
}
