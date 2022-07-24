part of minerva_server;

class AppSetting {
  static AppSetting? _instance;

  File? _file;

  late final String _path;

  late final Map<String, dynamic> _data;

  String? get host => _data['host'];

  int? get port {
    var port = _data['port'];

    if (port == null) {
      return null;
    } else {
      return int.parse(port);
    }
  }

  Map<String, dynamic>? get values => _data['values'];

  AppSetting._();

  static Future<AppSetting> get instance async {
    if (_instance == null) {
      _instance = AppSetting._();

      await _instance!._initialize();
    }

    return _instance!;
  }

  Future<void> _initialize() async {
    var appSettingDirectory =
        Directory.fromUri(Uri.directory(Platform.script.path)).parent.parent;

    _path = '${appSettingDirectory.path}/appsetting.json';

    _file = File.fromUri(Uri.file(_path));

    if (!await _file!.exists()) {
      throw AppSettingException(
          message: 'The appsetting.json file not exist by path: $_path.');
    }

    try {
      _data = jsonDecode(await _file!.readAsString());
    } catch (_) {
      throw AppSettingException(
          message:
              'An error occurred while parsing appsetting.json file by path: $_path.');
    }
  }

  Future<void> setValues(Map<String, dynamic> values) async {
    _data['values'] = values;

    var json = jsonEncode(_data);

    await _save(json);
  }

  Future<void> _save(String data) async {
    if (await _file!.exists()) {
      await _file!.writeAsString(data);
    } else {
      throw AppSettingException(
          message: 'The setting.json file not exist by path: $_path.');
    }
  }
}
