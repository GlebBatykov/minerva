part of minerva_cli;

class ConfigureGitIgnoreCLICommand extends CLICommand<void> {
  final String projectPath;

  ConfigureGitIgnoreCLICommand(this.projectPath);

  @override
  Future<void> run() async {
    final gitIgnoreFile = File.fromUri(Uri.file('$projectPath/.gitignore'));

    await gitIgnoreFile.create(recursive: true);

    await gitIgnoreFile.writeAsString('''
/build
/.dart_tool
.packages
test/test_app_setting.g.dart
''');
  }
}
