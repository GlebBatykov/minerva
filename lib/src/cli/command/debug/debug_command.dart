part of minerva_cli;

class DebugCommand extends Command {
  @override
  String get name => 'debug';

  @override
  String get description =>
      'Run Minerva server, as well as Dart VM services for debugging.';

  @override
  String get usage => '''
    -d  --directory               points to the project directory.
    -m  --mode                    sets the project build mode. Possible values: debug (default), release.
    -p  --pause-isolates-on-start pause isolates on start.
    -e  --enable-asserts          enable assert statements.
  ''';

  late final String _directoryPath;

  late final String _mode;

  late final bool _isPauseIsolatesOnStart;

  late final bool _isEnalbeAsserts;

  DebugCommand() {
    argParser.addOption('directory',
        abbr: 'd', defaultsTo: Directory.current.path);
    argParser.addOption('mode',
        abbr: 'm', defaultsTo: 'debug', allowed: ['debug', 'release']);
    argParser.addFlag('pause-isolates-on-start', abbr: 'p');
    argParser.addFlag('enable-asserts', abbr: 'e');
  }

  @override
  Future<void> run() async {
    _directoryPath =
        Directory.fromUri(Uri.parse(argResults!['directory'])).absolute.path;

    _mode = argResults!['mode'];

    _isPauseIsolatesOnStart = argResults!['pause-isolates-on-start'];

    _isEnalbeAsserts = argResults!['enable-asserts'];

    await _checkAppSetting();

    await _runBuild();

    stdout.writeln();

    await _runDebug();
  }

  Future<void> _checkAppSetting() async {
    late AppSettingParseResult appSettingParseResult;

    try {
      appSettingParseResult = await AppSettingParcer().parse(_directoryPath);
    } on AppSettingParserException catch (object) {
      usageException(object.message!);
    }

    var appSetting = appSettingParseResult.data;

    late Map<String, dynamic> currentBuildSetting;

    try {
      currentBuildSetting =
          BuildSettingParser().parseCurrent(appSetting, _mode);
    } on BuildSettingParserException catch (object) {
      usageException(object.message!);
    }

    var compileType = currentBuildSetting['compile-type'] as String?;

    if (compileType == null || compileType != 'JIT') {
      usageException(
          'To start debugging, the build compilation type must be JIT.');
    }
  }

  Future<void> _runBuild() async {
    var buildProcess = await Process.start(
        'minerva', ['build', '-d', _directoryPath, '-m', _mode]);

    buildProcess.stdout.listen((event) => stdout.add(event));
    buildProcess.stderr.listen((event) => stderr.add(event));

    await buildProcess.exitCode;
  }

  Future<void> _runDebug() async {
    var entryPointPath = '$_directoryPath/build/$_mode/bin/main.dill';

    var appProcess = await Process.start('dart', [
      'run',
      '--observe',
      if (_isPauseIsolatesOnStart) '--pause-isolates-on-start',
      if (_isEnalbeAsserts) '--enable-asserts',
      entryPointPath
    ]);

    appProcess.stdout.listen((event) => stdout.add(event));
    appProcess.stderr.listen((event) => stdout.add(event));

    await appProcess.exitCode;
  }
}
