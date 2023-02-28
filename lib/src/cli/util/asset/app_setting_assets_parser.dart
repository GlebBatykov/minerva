part of minerva_cli;

class AppSettingAssetsParser {
  List<String> parse(
    AppSetting appSetting,
    CurrentBuildAppSetting buildAppSetting,
  ) {
    final assets = <String>[];

    if (appSetting.assets != null) {
      assets.addAll(appSetting.assets!);
    }

    if (buildAppSetting.assets != null) {
      assets.addAll(appSetting.assets!);
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
