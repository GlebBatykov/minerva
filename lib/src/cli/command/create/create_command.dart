part of minerva_cli;

class CreateCommand extends Command {
  @override
  String get name => 'create';

  @override
  String get description => 'Create new project.';

  @override
  String get usage => '''
    -$nameOptionAbbr,   --$nameOptionName                  required parameter specifying the name of the project.
    -$templateOptionAbbr,   --$templateOptionName              specifies project template.

       [${ProjectTemplate.controllers.name}](default)     project that uses controllers to configure endpoints.
       [${ProjectTemplate.endpoints.name}]                simple project, endpoints are created manually.

    -$debugCompileTypeOptionAbbr,   --$debugCompileTypeOptionName    specifies compile type of debug build of project. Possible values: AOT, JIT (default).
    -$releaseCompileTypeOptionAbbr,   --$releaseCompileTypeOptionName  specifies compile type of release build of project. Possible values: AOT (default), JIT.
    -$dockerCompileTypeOptionAbbr,   --$dockerCompileTypeOptionName   specifies the compilation type to be used in the docker container. Possible values: AOT (default), JIT.                  
  ''';

  String? _projectName;

  late final ProjectTemplate _projectTemplate;

  CreateCommand() {
    argParser.addOption(
      nameOptionName,
      abbr: nameOptionAbbr,
    );
    argParser.addOption(
      debugCompileTypeOptionName,
      abbr: debugCompileTypeOptionAbbr,
      defaultsTo: CompileType.jit.toString(),
      allowed: CompileType.values.map((e) => e.name),
    );
    argParser.addOption(
      releaseCompileTypeOptionName,
      abbr: releaseCompileTypeOptionAbbr,
      defaultsTo: CompileType.aot.toString(),
      allowed: CompileType.values.map((e) => e.name),
    );
    argParser.addOption(
      dockerCompileTypeOptionName,
      abbr: dockerCompileTypeOptionAbbr,
      defaultsTo: CompileType.aot.toString(),
      allowed: CompileType.values.map((e) => e.name),
    );
    argParser.addOption(
      templateOptionName,
      abbr: templateOptionAbbr,
      defaultsTo: ProjectTemplate.controllers.name,
      allowed: ProjectTemplate.values.map((e) => e.name),
    );
  }

  @override
  Future<void> run() async {
    final args = argResults!;

    _projectName = args[nameOptionName];

    if (_projectName == null) {
      usageException('Project name must be specified.');
    }

    final projectPath = '${Directory.current.path}/$_projectName';

    final debugCompileType =
        CompileType.fromName(args[debugCompileTypeOptionName]);

    final releaseCompileType =
        CompileType.fromName(args[releaseCompileTypeOptionName]);

    final dockerCompileType =
        CompileType.fromName(args[dockerCompileTypeOptionName]);

    _projectTemplate = ProjectTemplate.fromName(args[templateOptionName]);

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
