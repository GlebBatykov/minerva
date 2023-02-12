part of minerva_cli;

class ConfigureReadmeCLICommand extends CLICommand<void> {
  final String projectName;

  final String projectPath;

  ConfigureReadmeCLICommand(this.projectName, this.projectPath);

  @override
  Future<void> run() async {
    final readmeFile = File.fromUri(Uri.file('$projectPath/README.md'));

    await readmeFile.create(recursive: true);

    await readmeFile.writeAsString('''
# $projectName

A new Minerva project.

## Getting Started

This project is a starting point for a Minerva application.

A few resources to get you started if this is your first Minerva project:

- [Documentation](https://github.com/GlebBatykov/minerva)
- [Examples](https://github.com/GlebBatykov/minerva_examples)
''');
  }
}
