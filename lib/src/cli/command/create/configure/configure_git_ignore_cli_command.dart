part of minerva_cli;

class ConfigureGitIgnoreCLICommand extends CLICommand<void> {
  final String projectPath;

  ConfigureGitIgnoreCLICommand(this.projectPath);

  @override
  Future<void> run() async {
    var gitIgnoreFile = File.fromUri(Uri.file('$projectPath/.gitignore'));

    await gitIgnoreFile.create();

    await gitIgnoreFile.writeAsString('''
/build
/.dart_tool
.packages
pubspec.lock
test/test_app_setting.g.dart
''');
  }
}
