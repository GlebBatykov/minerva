part of minerva_cli;

class RunCommand extends Command {
  @override
  String get name => 'run';

  @override
  String get description => 'Run Minerva server.';

  @override
  String get usage => '''
    -d  --directory points to the project directory.
    -m  --mode      sets the project build mode. Possible values: debug (default), release.
  ''';

  late final String _directoryPath;

  late final String _mode;

  RunCommand() {
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

    var setting = jsonDecode(await appSettingFile.readAsString())[_mode];

    if (setting == null) {
      usageException(
          'Setting for $_mode mode is not exist in appsetting.json file.');
    }

    await _runBuild();

    var compileType = setting['compile-type'] ?? 'AOT';

    late Process appProcess;

    if (compileType == 'AOT') {
      appProcess =
          await Process.start('$_directoryPath/build/$_mode/bin/main', []);
    } else {
      appProcess = await Process.start(
          'dart', ['$_directoryPath/build/$_mode/lib/main.dart']);
    }

    appProcess.stdout.listen((event) => stdout.add(event));
    appProcess.stderr.listen((event) => stdout.add(event));

    await appProcess.exitCode;
  }

  Future<void> _runBuild() async {
    var buildProcess = await Process.start(
        'minerva', ['build', '-d', _directoryPath, '-m', _mode]);

    buildProcess.stdout.listen((event) => stdout.add(event));
    buildProcess.stderr.listen((event) => stdout.add(event));

    await buildProcess.exitCode;

    stdout.writeln();
  }
}
