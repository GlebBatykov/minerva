part of minerva_cli;

class FinalBuildAppSetting {
  final String host;

  final int port;

  final BuildType buildType;

  final Map<String, dynamic>? values;

  final Map<String, List<String>>? logging;

  FinalBuildAppSetting(
    this.host,
    this.port,
    this.buildType, {
    this.values,
    this.logging,
  });

  Map<String, dynamic> toJson() => {
        'host': host,
        'port': port,
        'build-type': buildType.toString(),
        if (values != null) 'values': values,
        if (logging != null) 'logging': logging,
      };
}
