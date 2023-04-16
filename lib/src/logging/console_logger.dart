part of minerva_logging;

/// Logger for logging to the console.
class ConsoleLogger extends Logger {
  final String _template;

  final List<LoggerMiddleware> _middlewares = const [
    TimeMiddleware(),
    DateMiddleware(),
    LogLevelMiddleware(),
    MessageMiddleware()
  ];

  ConsoleLogger({
    String template = '[&time] [&level] &message',
  })  : _template = template,
        super(name: 'console');

  @override
  void info(
    Object? object, {
    String? template,
  }) {
    if (isLevelEnabled(LogLevel.info)) {
      _log(
        object: object,
        template: template ?? _template,
        level: LogLevel.info,
      );
    }
  }

  @override
  void debug(
    Object? object, {
    String? template,
  }) {
    if (isLevelEnabled(LogLevel.debug)) {
      _log(
        object: object,
        template: template ?? _template,
        level: LogLevel.debug,
      );
    }
  }

  @override
  void warning(
    Object? object, {
    String? template,
  }) {
    if (isLevelEnabled(LogLevel.warning)) {
      _log(
        object: object,
        template: template ?? _template,
        level: LogLevel.warning,
      );
    }
  }

  @override
  void error(
    Object? object, {
    String? template,
  }) {
    if (isLevelEnabled(LogLevel.error)) {
      _log(
        object: object,
        template: template ?? _template,
        level: LogLevel.error,
      );
    }
  }

  @override
  void critical(
    Object? object, {
    String? template,
  }) {
    if (isLevelEnabled(LogLevel.critical)) {
      _log(
        object: object,
        template: template ?? _template,
        level: LogLevel.critical,
      );
    }
  }

  void _log({
    required Object? object,
    required String template,
    required LogLevel level,
  }) {
    var log = Log(template, level, object.toString());

    for (var i = 0; i < _middlewares.length; i++) {
      log = _middlewares[i].handle(log);
    }

    print('${log.template}\n');
  }
}
