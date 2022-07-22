part of minerva_cli;

class Create extends Command {
  @override
  String get name => 'create';

  @override
  String get description => 'Create new project.';

  @override
  String get usage => '''
    -n,   --name                  required parameter specifying the name of the project.
    -d,   --directory             parameter indicating the directory in which the directory with the project will be created.
    -c,   --compile-type          specifies compile type of project. Possible values: AOT (default), JIT.
  ''';

  Create() {
    argParser.addOption('name', abbr: 'n');
    argParser.addOption('directory',
        abbr: 'd', defaultsTo: Directory.current.path);
    argParser.addOption('compile-type',
        abbr: 'c', defaultsTo: 'AOT', allowed: ['AOT', 'JIT']);
  }

  @override
  Future<void> run() async {
    var results = argResults!;

    var projectName = results['name'];

    var directoryPath = results['directory'];

    if (projectName == null) {
      usageException('Project name must be specified.');
    }

    var directory = Directory.fromUri(Uri.directory(directoryPath));

    if (await directory.exists() &&
        (await directory.list().toList())
            .where((element) => basename(element.path) == projectName)
            .isNotEmpty) {
      usageException(
          'Current directory already exist directory with name: $projectName.');
    }

    await ProjectCreateCommand(projectName, directoryPath).run();

    var projectPath = '$directoryPath/$projectName';

    var compileType = results['compile-type'];

    var pipeline = CLIPipeline([
      ProjectClearCommand(projectPath),
      ConfigureProjectCommand(projectName, projectPath, compileType),
      ConfigureDockerCommand(projectPath)
    ]);

    await pipeline.run();
  }
}
