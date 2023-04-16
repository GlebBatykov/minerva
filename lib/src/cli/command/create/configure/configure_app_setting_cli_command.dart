part of minerva_cli;

class ConfigureAppSettingCLICommand extends CLICommand<void> {
  final String projectPath;

  final CompileType debugCompileType;

  final CompileType releaseCompileType;

  ConfigureAppSettingCLICommand({
    required this.projectPath,
    required this.debugCompileType,
    required this.releaseCompileType,
  });

  @override
  Future<void> run() async {
    final appSettingFile =
        File.fromUri(Uri.file('$projectPath/appsetting.json'));

    await appSettingFile.create(
      recursive: true,
    );

    final appSetting = <String, Object?>{};

    appSetting['debug'] = <String, Object?>{
      'compile-type': debugCompileType.toString(),
      'host': '127.0.0.1',
      'port': 5000,
    };

    appSetting['release'] = <String, Object?>{
      'compile-type': releaseCompileType.toString(),
      'host': '0.0.0.0',
      'port': 8080,
    };

    appSetting['build'] = {
      'test': {
        'createAppSetting': true,
      }
    };

    final json = jsonEncode(appSetting);

    await appSettingFile.writeAsString(json);
  }
}
