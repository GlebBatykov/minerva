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

  late final BuildMode _mode;

  late final bool _isPauseIsolatesOnStart;

  late final bool _isEnalbeAsserts;

  DebugCommand() {
    argParser.addOption(
      'directory',
      abbr: 'd',
      defaultsTo: Directory.current.path,
    );
    argParser.addOption('mode',
        abbr: 'm',
        defaultsTo: BuildMode.debug.toString(),
        allowed: BuildMode.values.map(
          (e) => e.name,
        ));
    argParser.addFlag(
      'pause-isolates-on-start',
      abbr: 'p',
    );
    argParser.addFlag(
      'enable-asserts',
      abbr: 'e',
    );
  }

  @override
  Future<void> run() async {
    _directoryPath =
        Directory.fromUri(Uri.parse(argResults!['directory'])).absolute.path;

    _mode = BuildMode.fromName(argResults!['mode']);

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

    final appSetting = appSettingParseResult.data;

    late final CurrentBuildAppSetting currentBuildSetting;

    try {
      currentBuildSetting = CurrentBuildSettingParser().parseCurrent(
        appSetting,
        _mode,
      );
    } on BuildSettingParserException catch (object) {
      usageException(object.message!);
    }

    final compileType = currentBuildSetting.compileType;

    if (compileType == null || compileType != CompileType.jit) {
      usageException(
          'To start debugging, the build compilation type must be JIT.');
    }
  }

  Future<void> _runBuild() async {
    final buildProcess = await Process.start('minerva', [
      'build',
      '-d',
      _directoryPath,
      '-m',
      _mode.toString(),
    ]);

    buildProcess.stdout.listen((e) => stdout.add(e));
    buildProcess.stderr.listen((e) => stderr.add(e));

    await buildProcess.exitCode;
  }

  Future<void> _runDebug() async {
    final entryPointPath = '$_directoryPath/build/$_mode/bin/main.dill';

    final appProcess = await Process.start('dart', [
      'run',
      '--observe',
      if (_isPauseIsolatesOnStart) '--pause-isolates-on-start',
      if (_isEnalbeAsserts) '--enable-asserts',
      entryPointPath,
    ]);

    appProcess.stdout.listen((e) => stdout.add(e));
    appProcess.stderr.listen((e) => stdout.add(e));

    await appProcess.exitCode;
  }
}
