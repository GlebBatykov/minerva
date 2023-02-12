part of minerva_cli;

enum CompileType {
  jit('JIT'),
  aot('AOT');

  final String name;

  const CompileType(this.name);

  static CompileType fromName(String value) {
    return CompileType.values.firstWhere((e) => e.name == value);
  }

  @override
  String toString() {
    return name;
  }
}

enum ProjectTemplate {
  controllers('controllers'),
  endpoints('endpoints');

  final String name;

  const ProjectTemplate(this.name);

  static ProjectTemplate fromName(String value) {
    return ProjectTemplate.values.firstWhere((e) => e.name == value);
  }

  @override
  String toString() {
    return name;
  }
}

enum BuildMode {
  debug('debug'),
  release('release');

  final String name;

  const BuildMode(this.name);

  static BuildMode fromName(String value) {
    return BuildMode.values.firstWhere((e) => e.name == value);
  }

  @override
  String toString() {
    return name;
  }
}

enum FileLogType { source, appsetting, asset }
