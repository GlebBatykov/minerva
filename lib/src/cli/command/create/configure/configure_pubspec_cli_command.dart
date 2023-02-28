part of minerva_cli;

class ConfigurePubspecCLICommand extends CLICommand<void> {
  final String projectName;

  final String projectPath;

  final ProjectTemplate projectTemplate;

  ConfigurePubspecCLICommand({
    required this.projectName,
    required this.projectPath,
    required this.projectTemplate,
  });

  @override
  Future<void> run() async {
    final pubSpecFile = File.fromUri(Uri.file('$projectPath/pubspec.yaml'));

    await pubSpecFile.create(
      recursive: true,
    );

    await pubSpecFile.writeAsString(_getContent());
  }

  String _getContent() {
    switch (projectTemplate) {
      case ProjectTemplate.controllers:
        return '''
publish_to: none
name: $projectName
description: Minerva application.
version: 1.0.0

environment:
  sdk: '>=2.17.5 <3.0.0'

dependencies:
  minerva: ^${CLIConfiguration.minervaVersion}
  minerva_controller_generator: ^${CLIConfiguration.minervaControllerGeneratorVersion}
  build_runner: ^${CLIConfiguration.buildRunnerVersion}

dev_dependencies:
  lints: ^2.0.0
  test: ^1.16.0
  dio: ^4.0.6
''';
      case ProjectTemplate.endpoints:
        return '''
publish_to: none
name: $projectName
description: Minerva application.
version: 1.0.0

environment:
  sdk: '>=2.17.5 <3.0.0'

dependencies:
  minerva: ^${CLIConfiguration.minervaVersion}

dev_dependencies:
  lints: ^2.0.0
  test: ^1.16.0
  dio: ^4.0.6
''';
    }
  }
}
