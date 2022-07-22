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

    var appSettingFile =
        File.fromUri(Uri.file('$_directoryPath/appsetting.json'));

    if (!await appSettingFile.exists()) {
      usageException('Current directory not exist appsetting.json file.');
    }

    var appSetting =
        jsonDecode(await appSettingFile.readAsString()) as Map<String, dynamic>;

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

    var compileType = currentBuildSetting['compile-type'] ?? 'AOT';

    var isNeedClear = await _isNeedClearBuildDirectory(compileType);

    if (isNeedClear) {
      await _clearBuildDirectory();
    }

    if (compileType == 'AOT') {
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
    var buildDirectory =
        Directory.fromUri(Uri.directory('$_directoryPath/build/$_mode'));

    if (await buildDirectory.exists()) {
      print('The build folder is being cleared...');

      await buildDirectory.delete(recursive: true);

      print('The build folder has been cleared...');
    }
  }

  Future<void> _buildAOT(Map<String, dynamic> appSetting,
      Map<String, dynamic> buildSetting) async {
    try {
      var detailsFile =
          File.fromUri(Uri.file('$_directoryPath/build/$_mode/details.json'));

      var isNeedBuild = await _isNeedBuild(detailsFile);

      if (isNeedBuild) {
        await _clearBuildDirectory();

        await CompileCLICommand(_directoryPath, _mode).run();

        await _createBuildAppSetting(appSetting, buildSetting);
      }
    } on CLICommandException catch (object) {
      usageException(object.message);
    }
  }

  Future<void> _buildJIT(Map<String, dynamic> appSetting,
      Map<String, dynamic> buildSetting) async {
    try {
      var detailsFile =
          File.fromUri(Uri.file('$_directoryPath/build/$_mode/details.json'));

      var isNeedBuild = await _isNeedBuild(detailsFile);

      if (isNeedBuild) {
        await _clearBuildDirectory();

        Future.wait([
          _transferDartFiles(),
          _createBuildAppSetting(appSetting, buildSetting)
        ]);
      }
    } on CLICommandException catch (object) {
      usageException(object.message);
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

    if (!details.containsKey('fileLogs')) {
      return true;
    }

    var libDirectory = Directory.fromUri(Uri.directory('$_directoryPath/lib'));

    var dartFiles = (await libDirectory.list(recursive: true).toList())
        .whereType<File>()
        .where((element) => element.fileExtension == 'dart');

    var fileLogs = (details['fileLogs'] as List).cast<Map<String, dynamic>>();

    if (dartFiles.length < fileLogs.length) {
      return true;
    }

    for (var fileLog in fileLogs) {
      var files = dartFiles
          .where((element) => element.absolute.path == fileLog['path']);

      if (files.isEmpty) {
        return true;
      }

      var file = files.first;

      var fileStat = await file.stat();

      if (fileStat.modified
          .isAfter(DateTime.parse(fileLog['modificationTime']))) {
        return true;
      }
    }

    return false;
  }

  Future<void> _transferDartFiles() async {
    var libDirectory = Directory.fromUri(Uri.directory('$_directoryPath/lib'));

    var entities = await libDirectory.list().toList();

    var files = entities
        .whereType<File>()
        .where((element) => element.fileExtension == 'dart');

    var buildLibPath = '$_directoryPath/build/$_mode/lib';

    var buildLibdirectory = Directory.fromUri(Uri.directory(buildLibPath));

    await buildLibdirectory.create(recursive: true);

    var futures = <Future>[];

    var fileLogs = <Map<String, dynamic>>[];

    for (var file in files) {
      var filePathSegment = file.pathStartingFrom('lib');

      var buildfilePath = '$buildLibPath/$filePathSegment';

      var buildFile = File.fromUri(Uri.file(buildfilePath));

      var entityStat = await file.stat();

      var modificationTime = entityStat.modified;

      fileLogs.add({
        'path': file.absolute.path,
        'modificationTime': modificationTime.toString()
      });

      futures.add(buildFile.create(recursive: true).then(
          (value) async => buildFile.writeAsBytes(await file.readAsBytes())));
    }

    await Future.wait(futures);

    var detailsFile =
        File.fromUri(Uri.file('$_directoryPath/build/$_mode/details.json'));

    var details = <String, dynamic>{
      'compile-type': 'JIT',
      'fileLogs': fileLogs
    };

    var json = jsonEncode(details);

    await detailsFile.writeAsString(json);
  }

  Future<void> _createBuildAppSetting(Map<String, dynamic> appSetting,
      Map<String, dynamic> buildSetting) async {
    var buildAppSettingFile =
        File.fromUri(Uri.file('$_directoryPath/build/$_mode/appsetting.json'));

    await buildAppSettingFile.create(recursive: true);

    var buildAppSetting = appSetting;

    buildAppSetting.remove('debug');
    buildAppSetting.remove('release');

    buildAppSetting['host'] = buildSetting['host'];
    buildAppSetting['port'] = buildSetting['port'];

    await buildAppSettingFile.writeAsString(jsonEncode(buildAppSetting));
  }
}
