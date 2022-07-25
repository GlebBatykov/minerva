part of minerva_cli;

class ProjectCreateCommand extends CLICommand<void> {
  final String projectName;

  final String directoryPath;

  ProjectCreateCommand(this.projectName, this.directoryPath);

  @override
  Future<void> run() async {
    var createProcess = await Process.start(
        'dart', ['create', '-t', 'console', projectName, directoryPath]);

    createProcess.stdout.listen((event) => stdout.add(event));
    createProcess.stderr.listen((event) => stdout.add(event));

    await createProcess.exitCode;
  }
}
