part of minerva_core;

class AppSetting {
  static AppSetting _instance = AppSetting._();

  late final File _file;

  final String _path = '${HostEnvironment.contentRootPath}/appsetting.json';

  final Map<String, dynamic> _data = {};

  bool _isInitialized = false;

  String? get host => _data['host'];

  int? get port => _data['port'];

  String? get buildType => _data['build-type'];

  Map<String, dynamic>? get values => _data['values'];

  Map<String, List<String>>? get logging => _data['logging'];

  bool get isInitialized => _isInitialized;

  AppSetting._() {
    _file = File.fromUri(Uri.parse(_path));
  }

  static AppSetting get instance => _instance;

  static AppSetting get newInstance {
    _instance = AppSetting._();

    return _instance;
  }

  Future<void> initialize() async {
    if (!await _file.exists()) {
      throw AppSettingException(
          message: 'The appsetting.json file not exist by path: $_path.');
    }

    try {
      final data = jsonDecode(await _file.readAsString());

      _data.clear();

      _data.addAll(data);
    } catch (_) {
      throw AppSettingException(
          message:
              'An error occurred while parsing appsetting.json file by path: $_path.');
    }

    _isInitialized = true;
  }

  Future<void> setValues(Map<String, dynamic> values) async {
    _data['values'] = values;

    final json = jsonEncode(_data);

    await _save(json);
  }

  Future<void> _save(String data) async {
    if (await _file.exists()) {
      await _file.writeAsString(data);
    } else {
      throw AppSettingException(
          message: 'The setting.json file not exist by path: $_path.');
    }
  }
}
