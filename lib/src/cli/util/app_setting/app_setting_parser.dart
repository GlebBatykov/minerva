part of minerva_cli;

class AppSettingParcer {
  Future<AppSettingParseResult> parse(String projectPath) async {
    final file = File.fromUri(
        Uri.file('$projectPath/appsetting.json', windows: Platform.isWindows));

    if (!await file.exists()) {
      throw AppSettingParserException(
          message: 'Current directory not exist appsetting.json file.');
    }

    final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;

    final data = AppSetting.fromJson(json);

    final result = AppSettingParseResult(file, data);

    return result;
  }
}

class AppSettingParseResult {
  final File file;

  final AppSetting data;

  AppSettingParseResult(this.file, this.data);
}
