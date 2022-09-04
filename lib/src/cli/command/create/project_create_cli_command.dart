part of minerva_cli;

class ProjectCreateCommand extends CLICommand<void> {
  final String projectName;

  ProjectCreateCommand(this.projectName);

  @override
  Future<void> run() async {
    var createProcess =
        await Process.start('dart', ['create', '-t', 'console', projectName]);

    await createProcess.exitCode;
  }
}
