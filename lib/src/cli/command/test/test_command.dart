part of minerva_cli;

class TestCommand extends Command {
  @override
  String get name => 'test';

  @override
  String get description => 'Run tests.';

  @override
  String get usage => '''
    -$directoryOptionAbbr  --$directoryOptionName points to the project directory.
    -$modeOptionAbbr  --$modeOptionName      sets the project build mode. Possible values: debug (default), release.
  ''';

  TestCommand() {
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
    final args = argResults!;

    final directoryPath = Directory.fromUri(Uri.directory(
      args[directoryOptionName],
      windows: Platform.isWindows,
    )).absolute.path;

    final mode = BuildMode.fromName(args[modeOptionName]);

    final appProcess = await RunApplicationCLICommand(
      directoryPath,
      mode,
    ).run();

    final testProcess = await Process.start(
      'dart',
      ['test'],
      runInShell: true,
    );

    testProcess.stdout.listen((e) => stdout.add(e));
    testProcess.stderr.listen((e) => stdout.add(e));

    await testProcess.exitCode;

    appProcess.kill();

    await appProcess.exitCode;
  }
}
