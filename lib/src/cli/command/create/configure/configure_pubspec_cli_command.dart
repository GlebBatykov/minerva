part of minerva_cli;

class ConfigurePubspecCLICommand extends CLICommand<void> {
  final String projectName;

  final String projectPath;

  ConfigurePubspecCLICommand(this.projectName, this.projectPath);

  @override
  Future<void> run() async {
    var pubSpecFile = File.fromUri(Uri.file('$projectPath/pubspec.yaml'));

    await pubSpecFile.create();

    await pubSpecFile.writeAsString('''
publish_to: none
name: $projectName
description: Minerva application.
version: 1.0.0

environment:
  sdk: '>=2.17.5 <3.0.0'

dependencies:
  minerva: ^0.1.9

dev_dependencies:
  lints: ^2.0.0
  test: ^1.16.0
  dio: ^4.0.6
''');
  }
}
