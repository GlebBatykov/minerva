part of minerva_logging;

/// Used for logging to a file.
///
/// To work, you need to add a FileLoggerAgent to the server. The FileLoggerAgent name and the agent name specified in FileLogger must match.
class FileLogger extends Logger {
  final String _template;

  final String _agentName;

  late final AgentConnector _connector;

  final List<LoggerMiddleware> _middlewares = [
    TimeMiddleware(),
    DateMiddleware(),
    LogLevelMiddleware(),
    MessageMiddleware()
  ];

  FileLogger(
      {String agentName = 'file_logger',
      String template = '[&time] [&level] &message'})
      : _template = template,
        _agentName = agentName,
        super(name: 'file');

  @override
  FutureOr<void> initialize(AgentConnectors connectors) {
    final connector = connectors[_agentName];

    if (connector != null) {
      _connector = connector;
    } else {
      throw FileLoggerException(
          message: 'File agent by name: $_agentName, not exist.');
    }
  }

  @override
  Future<void> critical(dynamic object, {String? template}) async {
    if (isLevelEnabled(LogLevel.critical)) {
      await _log(object, template ?? _template, LogLevel.critical);
    }
  }

  @override
  Future<void> debug(dynamic object, {String? template}) async {
    if (isLevelEnabled(LogLevel.debug)) {
      await _log(object, template ?? _template, LogLevel.debug);
    }
  }

  @override
  Future<void> error(dynamic object, {String? template}) async {
    if (isLevelEnabled(LogLevel.error)) {
      await _log(object, template ?? _template, LogLevel.error);
    }
  }

  @override
  Future<void> info(dynamic object, {String? template}) async {
    if (isLevelEnabled(LogLevel.info)) {
      await _log(object, template ?? _template, LogLevel.info);
    }
  }

  @override
  Future<void> warning(dynamic object, {String? template}) async {
    if (isLevelEnabled(LogLevel.warning)) {
      await _log(object, template ?? _template, LogLevel.warning);
    }
  }

  Future<void> _log(dynamic object, String template, LogLevel level) async {
    var log = Log(template, level, object.toString());

    for (final middleware in _middlewares) {
      log = middleware.handle(log);
    }

    final data = {'log': log.template};

    _connector.cast('log', data: data);
  }
}
