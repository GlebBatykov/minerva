part of minerva_server;

class AppSetting {
  static AppSetting? _instance;

  File? _file;

  late final String _path;

  late final Map<String, dynamic> _data;

  Map<String, dynamic> get data => Map.unmodifiable(_data);

  AppSetting._();

  static Future<AppSetting> get instance async {
    if (_instance == null) {
      _instance = AppSetting._();

      await _instance!._initialize();
    }

    return _instance!;
  }

  Future<void> _initialize() async {
    _path = '${Directory.current.path}/appsetting.json';

    _file = File.fromUri(Uri.file(_path));

    if (await _file!.exists()) {
      try {
        _data = jsonDecode(await _file!.readAsString());
      } catch (_) {
        throw AppSettingException(
            message:
                'An error occurred while parsing app setting.json file by path: $_path.');
      }
    } else {
      throw AppSettingException(
          message: 'The setting.json file not exist by path: $_path.');
    }
  }

  Future<void> setValues(Map<String, dynamic> values) async {
    _data['values'] = values;

    var json = jsonEncode(_data);

    if (await _file!.exists()) {
      await _file!.writeAsString(json);
    } else {
      throw AppSettingException(
          message: 'The setting.json file not exist by path: $_path.');
    }
  }
}
