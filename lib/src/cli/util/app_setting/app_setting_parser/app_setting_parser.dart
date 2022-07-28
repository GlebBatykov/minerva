part of minerva_cli;

class AppSettingParcer {
  Future<AppSettingParseResult> parse(String projectPath) async {
    var file = File.fromUri(
        Uri.file('$projectPath/appsetting.json', windows: Platform.isWindows));

    if (!await file.exists()) {
      throw AppSettingParserException(
          message: 'Current directory not exist appsetting.json file.');
    }

    var data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;

    var result = AppSettingParseResult(file, data);

    return result;
  }
}
