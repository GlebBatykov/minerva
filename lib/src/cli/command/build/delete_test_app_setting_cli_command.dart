part of minerva_cli;

class DeleteTestAppSettingCLICommand extends CLICommand<void> {
  final String projectPath;

  DeleteTestAppSettingCLICommand(this.projectPath);

  @override
  Future<void> run() async {
    final testAppSettingPath = '$projectPath/test/test_app_setting.g.dart';

    final testAppSettingFile = File.fromUri(Uri.file(
      testAppSettingPath,
      windows: Platform.isWindows,
    ));

    if (await testAppSettingFile.exists()) {
      await testAppSettingFile.delete();
    }
  }
}
