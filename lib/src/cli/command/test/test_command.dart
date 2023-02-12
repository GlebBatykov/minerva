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

    final appProcess =
        await RunApplicationCLICommand(directoryPath, mode).run();

    final testProcess = await Process.start('dart', ['test'], runInShell: true);

    testProcess.stdout.listen((event) => stdout.add(event));
    testProcess.stderr.listen((event) => stdout.add(event));

    await testProcess.exitCode;

    appProcess.kill();

    await appProcess.exitCode;
  }
}
