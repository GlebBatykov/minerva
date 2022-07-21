part of minerva_cli;

class CreateCommand extends Command {
  @override
  String get name => 'create';

  @override
  String get description => 'Create new project.';

  @override
  String get usage => '''
    -n,   --name                required parameter specifying the name of the project.
    -d,   --directory           parameter indicating the directory in which the directory with the project will be created.
    -c, --docker-compile-type   specifies the compilation type to be used in the docker container. Possible values: AOT (default), JIT.
  ''';

  CreateCommand() {
    argParser.addOption('name', abbr: 'n');
    argParser.addOption('directory',
        abbr: 'd', defaultsTo: Directory.current.path);
    argParser.addOption('docker-compile-type',
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

    var result = await Process.run(
        'dart', ['create', '-t', 'console', projectName, directoryPath]);

    if (result.exitCode == 0) {
      var projectPath = '$directoryPath/$projectName';

      await _clearDefaultProject(projectPath);
      await _createProjectStructure(projectPath);
      await _configureDocker(projectPath);
    } else {
      print('An error occurred while creating the Dart project.');
    }
  }

  Future<void> _clearDefaultProject(String projectPath) async {
    var libDirectory = Directory.fromUri(Uri.directory('$projectPath/lib'));

    var buildDirectory = Directory.fromUri(Uri.directory('$projectPath/build'));

    await buildDirectory.create();

    for (var entity in await libDirectory.list().toList()) {
      await entity.delete();
    }
  }

  Future<void> _createProjectStructure(String projectPath) async {}

  Future<void> _configureDocker(String projectPath) async {
    await _addDockerFile(projectPath);
    await _addDockerIgnore(projectPath);
  }

  Future<void> _addDockerIgnore(String projectPath) async {
    var filePath = '$projectPath/.dockerignore';

    var file = File.fromUri(Uri.file(filePath));

    await file.create();

    await file.writeAsString('''
.dockerignore
Dockerfile
build/
.dart_tool/
.git/
.github/
.gitignore
.pubignore
.package
    ''');
  }

  Future<void> _addDockerFile(String projectPath) async {
    var compileType = argResults!['docker-compile-type'];

    var filePath = '$projectPath/Dockerfile';

    var file = File.fromUri(Uri.file(filePath));

    await file.create();

    await file.writeAsString('''
FROM dart:stable AS build

WORKDIR /minerva
COPY pubspec.* ./
RUN dart pub get
RUN dart pub global activate minerva

COPY . .

${() {
      if (compileType == 'AOT') {
        return '''
RUN dart pub get --offline
RUN dart compile exe bin/main.dart -o bin/main
        ''';
      } else {
        return '''
RUN dart pub get --offline
        ''';
      }
    }()}

FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /minerva/bin/main /minerva/bin/

EXPOSE 8080

${() {
      if (compileType == 'AOT') {
        return 'CMD ["/minerva/bin/main"]';
      } else {
        return 'CMD ["dart", "/minerva/bin/main.dart"]';
      }
    }()}
    ''');
  }
}
