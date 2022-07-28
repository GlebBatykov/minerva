part of minerva_cli;

class AppSettingAssetsParser {
  List<String> parse(Map<String, dynamic> appSetting) {
    var assets = <String>[];

    try {
      if (appSetting.containsKey('assets')) {
        assets = (appSetting['assets'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      }
    } catch (object) {
      throw CLICommandException(
          message: 'Incorrect asset format in the appsetting.json file.');
    }

    for (var i = 0; i < assets.length; i++) {
      if (assets[i].isEmpty) {
        throw CLICommandException(
            message: 'The asset path [$i] should not be empty.');
      }
    }

    return assets;
  }
}
