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
    _directoryPath = argResults!['directory'];

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

    if (compileType == 'AOT') {
      await _buildAOT(appSetting, currentBuildSetting);
    } else {
      await _buildJIT(appSetting, currentBuildSetting);
    }
  }

  Future<void> _buildAOT(Map<String, dynamic> appSetting,
      Map<String, dynamic> buildSetting) async {
    try {
      await CompileCLICommand(_directoryPath, _mode).run();

      await _createBuildAppSetting(appSetting, buildSetting);
    } on CLICommandException catch (object) {
      usageException(object.message);
    }
  }

  Future<void> _buildJIT(Map<String, dynamic> appSetting,
      Map<String, dynamic> buildSetting) async {
    try {
      await _transferDartFiles();

      await _createBuildAppSetting(appSetting, buildSetting);
    } on CLICommandException catch (object) {
      usageException(object.message);
    }
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

    for (var file in files) {
      var filePathSegment = file.pathStartingFrom('lib');

      futures.add(File.fromUri(Uri.file('$buildLibPath/$filePathSegment'))
          .create(recursive: true));
    }

    await Future.wait(futures);
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
