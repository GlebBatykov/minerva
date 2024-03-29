part of minerva_cli;

class CreateDockerIgnoreCLICommand extends CLICommand<void> {
  final String projectPath;

  CreateDockerIgnoreCLICommand(this.projectPath);

  @override
  Future<void> run() async {
    final filePath = '$projectPath/.dockerignore';

    final file = File.fromUri(Uri.file(filePath));

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
}
