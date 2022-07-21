part of minerva_logging;

class Log {
  final LogLevel level;

  final String message;

  String template;

  Log(this.template, this.level, this.message);
}
