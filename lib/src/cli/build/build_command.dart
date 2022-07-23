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

    _appSettingFile = File.fromUri(Uri.file('$_directoryPath/appsetting.json'));

    if (!await _appSettingFile.exists()) {
      usageException('Current directory not exist appsetting.json file.');
    }

    var appSetting = jsonDecode(await _appSettingFile.readAsString())
        as Map<String, dynamic>;

    var currentBuildSetting = appSetting[_mode] as Map<String, dynamic>?;

    if (currentBuildSetting == null) {
      usageException(
          'Setting for $_mode mode is not exist in appsetting.json file.');
    }

    if (!currentBuildSetting.containsKey('host') ||
        !currentBuildSetting.containsKey('port')) {
      usageException(
          'Setting for $_mode mode not contains host and port values.');
    }

    _compileType = currentBuildSetting['compile-type'] ?? 'AOT';

    var isNeedClear = await _isNeedClearBuildDirectory(_compileType);

    if (isNeedClear) {
      await _clearBuildDirectory();
    }

    if (_compileType == 'AOT') {
      await _buildAOT(appSetting, currentBuildSetting);
    } else {
      await _buildJIT(appSetting, currentBuildSetting);
    }
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
      print('The build folder is being cleared...');

      await ClearDirectoryCLICommand(buildDirectoryPath).run();

      print('The build folder has been cleared...');
    }
  }

  Future<void> _buildAOT(Map<String, dynamic> appSetting,
      Map<String, dynamic> buildSetting) async {
    print('Build AOT...');

    try {
      var detailsFile =
          File.fromUri(Uri.file('$_directoryPath/build/$_mode/details.json'));

      var isNeedBuild = await _isNeedBuild(detailsFile);

      if (isNeedBuild) {
        await _clearBuildDirectory();

        var fileLogs = <FileLog>[];

        var futures = <Future>[];

        futures.add(CompileCLICommand(_directoryPath, _mode)
            .run()
            .then((value) => fileLogs.addAll(value)));

        futures.add(CreateBuildAppSettingCLICommand(
                _directoryPath, _mode, appSetting, buildSetting)
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

  Future<void> _buildJIT(Map<String, dynamic> appSetting,
      Map<String, dynamic> buildSetting) async {
    print('Build JIT...');

    try {
      var detailsFile =
          File.fromUri(Uri.file('$_directoryPath/build/$_mode/details.json'));

      var isNeedBuild = await _isNeedBuild(detailsFile);

      if (isNeedBuild) {
        await _clearBuildDirectory();

        var fileLogs = <FileLog>[];

        var futures = <Future>[];

        futures.add(CopyPubSpecFileCLICommand(_directoryPath, _mode)
            .run()
            .then((value) => fileLogs.add(value)));

        futures.add(TransferFilesCLICommand(_directoryPath, _mode)
            .run()
            .then((value) => fileLogs.addAll(value)));

        futures.add(CreateBuildAppSettingCLICommand(
                _directoryPath, _mode, appSetting, buildSetting)
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
      usageException(object.toString());
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
}
