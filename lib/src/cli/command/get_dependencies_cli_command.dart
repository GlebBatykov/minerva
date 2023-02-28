part of minerva_cli;

class GetDependenciesCLICommand extends CLICommand<void> {
  final String projectPath;

  GetDependenciesCLICommand(this.projectPath);

  @override
  Future<void> run() async {
    final pubGetProcess = await Process.start('dart', [
      'pub',
      'get',
      '-C',
      projectPath,
    ]);

    pubGetProcess.stdout.listen((e) => stdout.add(e));
    pubGetProcess.stderr.listen((e) => stdout.add(e));

    await pubGetProcess.exitCode;
  }
}
