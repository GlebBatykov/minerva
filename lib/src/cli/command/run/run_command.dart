part of minerva_cli;

class RunCommand extends Command {
  @override
  String get name => 'run';

  @override
  String get description => 'Run Minerva server.';

  @override
  String get usage => '''
    -$directoryOptionAbbr  --$directoryOptionName points to the project directory.
    -$modeOptionAbbr  --$modeOptionName      sets the project build mode. Possible values: debug (default), release.
  ''';

  RunCommand() {
    argParser.addOption(
      directoryOptionName,
      abbr: directoryOptionAbbr,
      defaultsTo: Directory.current.path,
    );
    argParser.addOption(
      modeOptionName,
      abbr: modeOptionAbbr,
      defaultsTo: BuildMode.debug.toString(),
      allowed: BuildMode.values.map((e) => e.name),
    );
  }

  @override
  Future<void> run() async {
    final directoryPath = Directory.fromUri(Uri.directory(
      argResults![directoryOptionName],
      windows: Platform.isWindows,
    )).absolute.path;

    final mode = BuildMode.fromName(argResults![modeOptionName]);

    try {
      final appProcess = await RunApplicationCLICommand(
        directoryPath,
        mode,
      ).run();

      appProcess.stdout.listen((e) => stdout.add(e));
      appProcess.stderr.listen((e) => stdout.add(e));

      await appProcess.exitCode;
    } on CLICommandException catch (object) {
      usageException(object.message!);
    }
  }
}
