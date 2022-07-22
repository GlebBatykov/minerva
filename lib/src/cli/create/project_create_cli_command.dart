part of minerva_cli;

class ProjectCreateCommand extends CLICommand<void> {
  final String projectName;

  final String directoryPath;

  ProjectCreateCommand(this.projectName, this.directoryPath);

  @override
  Future<void> run() async {
    await Process.run(
        'dart', ['create', '-t', 'console', projectName, directoryPath]);
  }
}
