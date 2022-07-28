part of minerva_cli;

class GenerateTestAppSettingCLICommand extends CLICommand<void> {
  final String projectPath;

  final Map<String, dynamic> buildAppSetting;

  GenerateTestAppSettingCLICommand(this.projectPath, this.buildAppSetting);

  @override
  Future<void> run() async {
    var testAppSettingPath = '$projectPath/test/test_app_setting.g.dart';

    var testAppSettingFile =
        File.fromUri(Uri.file(testAppSettingPath, windows: Platform.isWindows));

    await testAppSettingFile.create(recursive: true);

    var host = buildAppSetting['host'] as String;

    var port = buildAppSetting['port'];

    await testAppSettingFile.writeAsString('''
// Generated automatically by Minerva. Do not edit with your hands.

abstract class TestAppSetting {
  static const String host = '$host';

  static const int port = $port;
}
''');
  }
}
