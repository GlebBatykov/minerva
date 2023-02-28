part of minerva_cli;

class BuildAppSetting {
  final String? host;

  final int? port;

  final CompileType? compileType;

  final Map<String, dynamic>? values;

  final List<String>? assets;

  final Map<String, List<String>>? logging;

  BuildAppSetting(
    this.host,
    this.port,
    this.compileType, {
    this.values,
    this.assets,
    this.logging,
  });

  BuildAppSetting.fromJson(Map<String, dynamic> json)
      : host = json['host'],
        port = json['port'],
        compileType = CompileType.fromName(json['compile-type']),
        values = json['values'],
        assets = json['assets'],
        logging = json['logging'];
}
