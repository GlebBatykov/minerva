part of minerva_cli;

class ProjectCreateCommand extends CLICommand<void> {
  final String projectName;

  ProjectCreateCommand(this.projectName);

  @override
  Future<void> run() async {
    var createProcess =
        await Process.start('dart', ['create', '-t', 'console', projectName]);

    createProcess.stdout.listen((event) => stdout.add(event));
    createProcess.stderr.listen((event) => stdout.add(event));

    await createProcess.exitCode;
  }
}
