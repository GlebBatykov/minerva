part of minerva_util;

class ConfigurationManager {
  final Map<String, dynamic> _data = {};

  Future<void> load() async {
    _data.clear();

    var appSetting = await AppSetting.instance;

    var data = appSetting.data;

    if (data.containsKey('values')) {
      var values = data['values'] as Map<String, dynamic>;

      _data.addAll(values);
    }
  }

  Future<void> save() async {
    var appSetting = await AppSetting.instance;

    await appSetting.setValues(_data);
  }

  void operator []=(String key, dynamic value) {
    _data[key] = value;
  }

  dynamic operator [](String key) {
    return _data[key];
  }
}
