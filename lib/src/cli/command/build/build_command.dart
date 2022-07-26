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

  BuildCommand() {
    argParser.addOption('directory',
        abbr: 'd', defaultsTo: Directory.current.path);
    argParser.addOption('mode',
        abbr: 'm', defaultsTo: 'debug', allowed: ['debug', 'release']);
  }

  @override
  Future<void> run() async {
    _directoryPath =
        Directory.fromUri(Uri.parse(argResults!['directory'])).absolute.path;

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

    _compileType = currentBuildSetting['compile-type'] ?? 'AOT';

    var isNeedClear = await _isNeedClearBuildDirectory(_compileType);

    if (isNeedClear) {
      await _clearBuildDirectory();
    }

    await _build(currentBuildSetting, _compileType);
  }

  Future<bool> _isNeedClearBuildDirectory(String compileType) async {
    var detailsFile =
        File.fromUri(Uri.file('$_directoryPath/build/$_mode/details.json'));

    var detailsFileExists = await detailsFile.exists();

    if (!detailsFileExists) {
      return true;
    }

    late Map<String, dynamic> details;

    try {
      details = jsonDecode(await detailsFile.readAsString());
    } catch (_) {
      return true;
    }

    if (!details.containsKey('compile-type')) {
      return true;
    }

    if (details['compile-type'] != compileType) {
      return true;
    }

    return false;
  }

  Future<void> _clearBuildDirectory() async {
    var buildDirectoryPath = '$_directoryPath/build/$_mode';

    var buildDirectory =
        Directory.fromUri(Uri.directory('$_directoryPath/build/$_mode'));

    if (await buildDirectory.exists()) {
      print('The $_mode build folder is being cleared...');

      await ClearDirectoryCLICommand(buildDirectoryPath).run();

      print('The $_mode build folder has been cleared...');
    }
  }

  Future<void> _build(
      Map<String, dynamic> buildSetting, String compileType) async {
    try {
      var detailsFile =
          File.fromUri(Uri.file('$_directoryPath/build/$_mode/details.json'));

      var isNeedBuild = await _isNeedBuild(detailsFile);

      if (isNeedBuild) {
        print('Build...');

        await _clearBuildDirectory();

        var fileLogs = <FileLog>[];

        var futures = <Future>[];

        var buildAppSetting = _createBuildAppSetting(_appSetting, buildSetting);

        futures.add(CompileCLICommand(_directoryPath, _mode, compileType)
            .run()
            .then((value) => fileLogs.addAll(value)));

        futures.add(CreateBuildAppSettingCLICommand(
                _directoryPath, _mode, buildAppSetting)
            .run());

        futures.add(CloneAssetsCLICommand(_directoryPath, _mode, _appSetting)
            .run()
            .then((value) => fileLogs.addAll(value)));

        futures.add(
            GenerateTestAppSettingCLICommand(_directoryPath, buildAppSetting)
                .run());

        await Future.wait(futures);

        var appSettingFileLog = await _getAppSettingFileLog();

        fileLogs.add(appSettingFileLog);

        await _createDetails(fileLogs);
      } else {
        print('Rebuild is not needed.');
      }
    } on CLICommandException catch (object) {
      usageException(object.message);
    } catch (object) {
      usageException('$object');
    }
  }

  Future<bool> _isNeedBuild(File detailsFile) async {
    var detailsFileExists = await detailsFile.exists();

    if (!detailsFileExists) {
      return true;
    }

    late Map<String, dynamic> details;

    try {
      details = jsonDecode(await detailsFile.readAsString());
    } catch (_) {
      return true;
    }

    if (!details.containsKey('files')) {
      return true;
    }

    var fileLogs = (details['files'] as List).map((e) => FileLog.fromJson(e));

    for (var fileLog in fileLogs) {
      var file = File.fromUri(Uri.file(fileLog.path));

      if (!await file.exists()) {
        return true;
      }

      var fileStat = await file.stat();

      if (fileStat.modified.isAfter(fileLog.modificationTime)) {
        return true;
      }
    }

    return false;
  }

  Future<FileLog> _getAppSettingFileLog() async {
    var appSettingFileStat = await _appSettingFile.stat();

    var modificationTime = appSettingFileStat.modified;

    var fileLog = FileLog(_appSettingFile.absolute.path, modificationTime);

    return fileLog;
  }

  Future<void> _createDetails(List<FileLog> fileLogs) async {
    var detailsFile =
        File.fromUri(Uri.file('$_directoryPath/build/$_mode/details.json'));

    var details = <String, dynamic>{
      'compile-type': _compileType,
      'files': fileLogs.map((e) => e.toJson()).toList()
    };

    var json = jsonEncode(details);

    await detailsFile.writeAsString(json);
  }

  Map<String, dynamic> _createBuildAppSetting(
      Map<String, dynamic> appSetting, Map<String, dynamic> buildSetting) {
    var buildAppSetting = appSetting;

    buildAppSetting.remove('debug');
    buildAppSetting.remove('release');
    buildAppSetting.remove('assets');

    buildAppSetting['host'] = buildSetting['host'];
    buildAppSetting['port'] = buildSetting['port'];

    if (buildSetting.containsKey('values')) {
      var buildValues = buildSetting['values'];

      if (buildAppSetting.containsKey('values')) {
        var values = (buildAppSetting['values'] as Map<String, dynamic>);

        values.addAll(buildValues);

        buildAppSetting['values'] = values;
      } else {
        buildAppSetting['values'] = buildValues;
      }
    }

    return buildAppSetting;
  }
}
