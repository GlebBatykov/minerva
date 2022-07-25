part of minerva_cli;

class TestCommand extends Command {
  @override
  String get name => 'test';

  @override
  String get description => 'Run tests.';

  @override
  String get usage => '''
    -d  --directory points to the project directory.
    -m  --mode      sets the project build mode. Possible values: debug (default), release.
  ''';

  TestCommand() {
    argParser.addOption('directory',
        abbr: 'd', defaultsTo: Directory.current.path);
    argParser.addOption('mode',
        abbr: 'm', defaultsTo: 'debug', allowed: ['debug', 'release']);
  }

  @override
  Future<void> run() async {
    var directoryPath =
        Directory.fromUri(Uri.parse(argResults!['directory'])).absolute.path;

    var mode = argResults!['mode'];

    var appProcess = await RunApplicationCLICommand(directoryPath, mode).run();

    var testProcess = await Process.start('dart', ['test']);

    testProcess.stdout.listen((event) => stdout.add(event));
    testProcess.stderr.listen((event) => stdout.add(event));

    await testProcess.exitCode;

    appProcess.kill();

    await appProcess.exitCode;
  }
}
