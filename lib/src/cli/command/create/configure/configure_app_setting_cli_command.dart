part of minerva_cli;

class ConfigureAppSettingCLICommand extends CLICommand<void> {
  final String projectPath;

  final CompileType debugCompileType;

  final CompileType releaseCompileType;

  ConfigureAppSettingCLICommand(
      this.projectPath, this.debugCompileType, this.releaseCompileType);

  @override
  Future<void> run() async {
    final appSettingFile =
        File.fromUri(Uri.file('$projectPath/appsetting.json'));

    await appSettingFile.create(recursive: true);

    final appSetting = <String, dynamic>{};

    appSetting['debug'] = <String, dynamic>{
      'compile-type': debugCompileType.toString(),
      'host': '127.0.0.1',
      'port': 5000,
    };

    appSetting['release'] = <String, dynamic>{
      'compile-type': releaseCompileType.toString(),
      'host': '0.0.0.0',
      'port': 8080
    };

    appSetting['build'] = {
      'test': {'createAppSetting': true}
    };

    final json = jsonEncode(appSetting);

    await appSettingFile.writeAsString(json);
  }
}
