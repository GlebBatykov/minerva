part of minerva_cli;

class GetDependenciesCLICommand extends CLICommand<void> {
  final String projectPath;

  GetDependenciesCLICommand(this.projectPath);

  @override
  Future<void> run() async {
    var pubGetProcess =
        await Process.start('dart', ['pub', 'get', '-C', projectPath]);

    pubGetProcess.stdout.listen((event) => stdout.add(event));
    pubGetProcess.stderr.listen((event) => stdout.add(event));

    await pubGetProcess.exitCode;
  }
}
