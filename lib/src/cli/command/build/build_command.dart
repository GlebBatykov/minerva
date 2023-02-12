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

  late final String _directoryPath;

  late final BuildMode _mode;

  late final CompileType _compileType;

  late final File _appSettingFile;

  late final AppSetting _appSetting;

  final Map<String, dynamic> _details = {};

  BuildCommand() {
    argParser.addOption('directory',
        abbr: 'd', defaultsTo: Directory.current.path);
    argParser.addOption('mode',
        abbr: 'm',
        defaultsTo: BuildMode.debug.toString(),
        allowed: BuildMode.values.map((e) => e.name));
  }

  @override
  Future<void> run() async {
    _directoryPath = Directory.fromUri(Uri.directory(argResults!['directory'],
            windows: Platform.isWindows))
        .absolute
        .path;

    _mode = BuildMode.fromName(argResults!['mode']);

    late AppSettingParseResult appSettingParseResult;

    try {
      appSettingParseResult = await AppSettingParcer().parse(_directoryPath);
    } on AppSettingParserException catch (object) {
      usageException(object.message!);
    }

    _appSetting = appSettingParseResult.data;

    _appSettingFile = appSettingParseResult.file;

    final currentBuildSetting =
        CurrentBuildSettingParser().parseCurrent(_appSetting, _mode);

    _compileType = _getCompileType(currentBuildSetting);

    final isNeedScratchBuild = await _isNeedBuildFromScratch();

    if (isNeedScratchBuild) {
      await _clearBuild();

      await _build(currentBuildSetting);
    } else {
      await _rebuild(currentBuildSetting);
    }
  }

  CompileType _getCompileType(CurrentBuildAppSetting buildSetting) {
    if (buildSetting.compileType != null) {
      return buildSetting.compileType!;
    } else {
      return CompileType.jit;
    }
  }

  Future<bool> _isNeedBuildFromScratch() async {
    final detailsFile = File.fromUri(Uri.file(
        '$_directoryPath/build/$_mode/details.json',
        windows: Platform.isWindows));

    final detailsFileExists = await detailsFile.exists();

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
    final buildDirectoryPath = '$_directoryPath/build/$_mode';

    final buildDirectory = Directory.fromUri(Uri.directory(
        '$_directoryPath/build/$_mode',
        windows: Platform.isWindows));

    if (await buildDirectory.exists()) {
      print('The $_mode build folder is being cleared...');

      await ClearDirectoryCLICommand(buildDirectoryPath).run();

      print('The $_mode build folder has been cleared...');
    }
  }

  Future<void> _build(CurrentBuildAppSetting buildSetting) async {
    try {
      await BuildCLICommand(_directoryPath, _mode, _compileType,
              _appSettingFile, _appSetting, buildSetting)
          .run();
    } on CLICommandException catch (object) {
      usageException(object.message!);
    } catch (object) {
      usageException(object.toString());
    }
  }

  Future<void> _rebuild(CurrentBuildAppSetting buildSetting) async {
    try {
      final fileLogs =
          (_details['files'] as List).map((e) => FileLog.fromJson(e)).toList();

      final buildCompileType = CompileType.fromName(_details['compile-type']);

      await RebuildCLICommand(
              _directoryPath,
              _mode,
              _compileType,
              _appSettingFile,
              _appSetting,
              buildSetting,
              buildCompileType,
              fileLogs)
          .run();
    } on CLICommandException catch (object) {
      usageException(object.message!);
    } catch (object) {
      usageException(object.toString());
    }
  }
}
