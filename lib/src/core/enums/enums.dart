part of minerva_core;

enum BuildType {
  debug('debug'),
  release('release');

  final String name;

  const BuildType(this.name);

  static BuildType fromName(String value) {
    return BuildType.values.firstWhere((e) => e.name == value);
  }

  @override
  String toString() {
    return name;
  }
}
