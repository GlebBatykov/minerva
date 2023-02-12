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
        abbr: 'm',
        defaultsTo: BuildMode.debug.toString(),
        allowed: BuildMode.values.map((e) => e.name));
  }

  @override
  Future<void> run() async {
    final directoryPath = Directory.fromUri(Uri.directory(
            argResults!['directory'],
            windows: Platform.isWindows))
        .absolute
        .path;

    final mode = BuildMode.fromName(argResults!['mode']);

    try {
      final appProcess =
          await RunApplicationCLICommand(directoryPath, mode).run();

      appProcess.stdout.listen((event) => stdout.add(event));
      appProcess.stderr.listen((event) => stdout.add(event));

      await appProcess.exitCode;
    } on CLICommandException catch (object) {
      usageException(object.message!);
    }
  }
}
