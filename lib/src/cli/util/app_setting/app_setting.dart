part of minerva_cli;

class AppSetting {
  final BuildAppSetting? debug;

  final BuildAppSetting? release;

  final BuildSetting buildSetting;

  final Map<String, dynamic>? values;

  final List<String>? assets;

  final Map<String, List<String>>? logging;

  AppSetting(this.debug, this.release,
      {this.values,
      this.buildSetting = const BuildSetting(),
      this.assets,
      this.logging});

  AppSetting.fromJson(Map<String, dynamic> json)
      : debug = BuildAppSetting.fromJson(json['debug']),
        release = BuildAppSetting.fromJson(json['release']),
        buildSetting = json['build'] != null
            ? BuildSetting.fromJson(json['build'])
            : BuildSetting(),
        values = json['values'],
        assets = json['assets'],
        logging = json['logging'];
}

class BuildSetting {
  final TestSetting testSetting;

  const BuildSetting({this.testSetting = const TestSetting()});

  BuildSetting.fromJson(Map<String, dynamic> json)
      : testSetting = TestSetting.fromJson(json['test'] ?? TestSetting());
}

class TestSetting {
  final bool createAppSetting;

  const TestSetting({this.createAppSetting = false});

  TestSetting.fromJson(Map<String, dynamic> json)
      : createAppSetting = json['createAppSetting'] ?? false;
}
