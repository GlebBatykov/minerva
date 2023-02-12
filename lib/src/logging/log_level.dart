part of minerva_logging;

enum LogLevel {
  info,
  debug,
  warning,
  error,
  critical;

  static LogLevel fromName(String name) {
    return LogLevel.values.firstWhere((e) => e.name == name);
  }
}
