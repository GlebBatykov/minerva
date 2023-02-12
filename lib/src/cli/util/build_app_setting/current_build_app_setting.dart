part of minerva_cli;

class CurrentBuildAppSetting {
  final String host;

  final int port;

  final CompileType? compileType;

  final Map<String, dynamic>? values;

  final List<String>? assets;

  final Map<String, List<String>>? logging;

  CurrentBuildAppSetting(this.host, this.port, this.compileType,
      {this.values, this.assets, this.logging});
}
