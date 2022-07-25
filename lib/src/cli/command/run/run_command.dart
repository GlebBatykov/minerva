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

  RunCommand() {
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

    appProcess.stdout.listen((event) => stdout.add(event));
    appProcess.stderr.listen((event) => stdout.add(event));

    await appProcess.exitCode;
  }
}
