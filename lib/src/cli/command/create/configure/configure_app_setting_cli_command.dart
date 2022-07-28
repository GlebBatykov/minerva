part of minerva_cli;

class ConfigureAppSettingCLICommand extends CLICommand<void> {
  final String projectPath;

  final String debugCompileType;

  final String releaseCompileType;

  ConfigureAppSettingCLICommand(
      this.projectPath, this.debugCompileType, this.releaseCompileType);

  @override
  Future<void> run() async {
    var appSettingFile = File.fromUri(Uri.file('$projectPath/appsetting.json'));

    await appSettingFile.create();

    var appSetting = <String, dynamic>{};

    appSetting['debug'] = <String, dynamic>{
      'compile-type': debugCompileType,
      'host': '127.0.0.1',
      'port': 5000,
    };

    appSetting['release'] = <String, dynamic>{
      'compile-type': releaseCompileType,
      'host': '0.0.0.0',
      'port': 8080
    };

    appSetting['assets'] = <String>['/assets'];

    var json = jsonEncode(appSetting);

    await appSettingFile.writeAsString(json);
  }
}
