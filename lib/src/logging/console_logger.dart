part of minerva_logging;

class ConsoleLogger extends Logger {
  final String _template;

  final List<LoggerMiddleware> _middlewares = [
    TimeMiddleware(),
    DateMiddleware(),
    LogLevelMiddleware(),
    MessageMiddleware()
  ];

  ConsoleLogger({String template = '[&time] [&level] &message'})
      : _template = template,
        super('console');

  @override
  void info(dynamic object, {String? template}) {
    if (isLevelEnabled(LogLevel.info)) {
      _log(object, template ?? _template, LogLevel.info);
    }
  }

  @override
  void debug(dynamic object, {String? template}) {
    if (isLevelEnabled(LogLevel.debug)) {
      _log(object, template ?? _template, LogLevel.debug);
    }
  }

  @override
  void warning(object, {String? template}) {
    if (isLevelEnabled(LogLevel.warning)) {
      _log(object, template ?? _template, LogLevel.warning);
    }
  }

  @override
  void error(object, {String? template}) {
    if (isLevelEnabled(LogLevel.error)) {
      _log(object, template ?? _template, LogLevel.error);
    }
  }

  @override
  void critical(object, {String? template}) {
    if (isLevelEnabled(LogLevel.critical)) {
      _log(object, template ?? _template, LogLevel.critical);
    }
  }

  void _log(dynamic object, String template, LogLevel level) {
    var log = Log(template, level, object.toString());

    for (var middleware in _middlewares) {
      log = middleware.handle(log);
    }

    print('${log.template}\n');
  }
}
