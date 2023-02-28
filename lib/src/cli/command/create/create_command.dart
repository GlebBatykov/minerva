part of minerva_cli;

class CreateCommand extends Command {
  @override
  String get name => 'create';

  @override
  String get description => 'Create new project.';

  @override
  String get usage => '''
    -n,   --name                  required parameter specifying the name of the project.
    -t,   --template              specifies project template.

       [controllers](default)     project that uses controllers to configure endpoints.
       [endpoints]                simple project, endpoints are created manually.

    -d,   --debug-compile-type    specifies compile type of debug build of project. Possible values: AOT, JIT (default).
    -r,   --release-compile-type  specifies compile type of release build of project. Possible values: AOT (default), JIT.
    -o,   --docker-compile-type   specifies the compilation type to be used in the docker container. Possible values: AOT (default), JIT.                  
  ''';

  String? _projectName;

  late final ProjectTemplate _projectTemplate;

  CreateCommand() {
    argParser.addOption(
      'name',
      abbr: 'n',
    );
    argParser.addOption(
      'debug-compile-type',
      abbr: 'c',
      defaultsTo: CompileType.jit.toString(),
      allowed: CompileType.values.map((e) => e.name),
    );
    argParser.addOption(
      'release-compile-type',
      abbr: 'r',
      defaultsTo: CompileType.aot.toString(),
      allowed: CompileType.values.map((e) => e.name),
    );
    argParser.addOption(
      'docker-compile-type',
      abbr: 'o',
      defaultsTo: CompileType.aot.toString(),
      allowed: CompileType.values.map((e) => e.name),
    );
    argParser.addOption(
      'template',
      abbr: 't',
      defaultsTo: 'controllers',
      allowed: [
        'controllers',
        'endpoints',
      ],
    );
  }

  @override
  Future<void> run() async {
    _projectName = argResults!['name'];

    if (_projectName == null) {
      usageException('Project name must be specified.');
    }

    final projectPath = '${Directory.current.path}/$_projectName';

    final debugCompileType =
        CompileType.fromName(argResults!['debug-compile-type']);

    final releaseCompileType =
        CompileType.fromName(argResults!['release-compile-type']);

    final dockerCompileType =
        CompileType.fromName(argResults!['docker-compile-type']);

    _projectTemplate = ProjectTemplate.fromName(argResults!['template']);

    print('Creating Minerva project with name $_projectName...');

    stdout.writeln();

    final pipeline = CLIPipeline([
      ConfigureProjectCLICommand(
        projectName: _projectName!,
        projectPath: projectPath,
        debugCompileType: debugCompileType,
        releaseCompileType: releaseCompileType,
        projectTemplate: _projectTemplate,
      ),
      CreateDockerIgnoreCLICommand(projectPath),
      CreateDockerFileCLICommand(
        projectPath,
        dockerCompileType,
      ),
      GetDependenciesCLICommand(projectPath),
    ]);

    await pipeline.run();

    stdout.writeln();

    print(_getSuccessCreateMessage());
  }

  String _getSuccessCreateMessage() {
    if (_projectTemplate == ProjectTemplate.controllers) {
      return '''
Created project $_projectName in $_projectName! In order to get started, run the following commands:

  cd $_projectName
  dart pub run build_runner build
  minerva run
''';
    } else {
      return '''
Created project $_projectName in $_projectName! In order to get started, run the following commands:

  cd $_projectName
  minerva run
''';
    }
  }
}
