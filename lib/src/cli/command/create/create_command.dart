part of minerva_cli;

class CreateCommand extends Command {
  @override
  String get name => 'create';

  @override
  String get description => 'Create new project.';

  @override
  String get usage => '''
    -n,   --name                  required parameter specifying the name of the project.
    -d,   --debug-compile-type    specifies compile type of debug build of project. Possible values: AOT, JIT (default).
    -r,   --release-compile-type  specifies compile type of release build of project. Possible values: AOT (default), JIT.
    -o,   --docker-compile-type   specifies the compilation type to be used in the docker container. Possible values: AOT (default), JIT.
  ''';

  CreateCommand() {
    argParser.addOption('name', abbr: 'n');
    argParser.addOption('debug-compile-type',
        abbr: 'c', defaultsTo: 'JIT', allowed: ['AOT', 'JIT']);
    argParser.addOption('release-compile-type',
        abbr: 'r', defaultsTo: 'AOT', allowed: ['AOT', 'JIT']);
    argParser.addOption('docker-compile-type',
        abbr: 'o', defaultsTo: 'AOT', allowed: ['AOT', 'JIT']);
  }

  @override
  Future<void> run() async {
    var projectName = argResults!['name'];

    if (projectName == null) {
      usageException('Project name must be specified.');
    }

    await ProjectCreateCommand(projectName).run();

    var projectPath = '${Directory.current.path}/$projectName';

    var debugCompileType = argResults!['debug-compile-type'];

    var releaseCompileType = argResults!['release-compile-type'];

    var dockerCompileType = argResults!['docker-compile-type'];

    var pipeline = CLIPipeline([
      ProjectClearCLICommand(projectPath),
      ConfigureProjectCLICommand(
          projectName, projectPath, debugCompileType, releaseCompileType),
      CreateDockerIgnoreCLICommand(projectPath),
      CreateDockerFileCLICommand(projectPath, dockerCompileType)
    ]);

    await pipeline.run();
  }
}
