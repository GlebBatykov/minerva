part of minerva_logging;

class LogPipeline {
  final List<Logger> _loggers;

  LogPipeline(List<Logger> loggers) : _loggers = loggers;

  Future<void> initialize() async {
    for (var logger in _loggers) {
      await logger.initialize();
    }
  }

  void info(dynamic object) {
    for (var logger in _loggers) {
      logger.info(object);
    }
  }

  void debug(dynamic object) {
    for (var logger in _loggers) {
      logger.debug(object);
    }
  }

  void warning(dynamic object) {
    for (var logger in _loggers) {
      logger.warning(object);
    }
  }

  void error(dynamic object) {
    for (var logger in _loggers) {
      logger.error(object);
    }
  }

  void critical(dynamic object) {
    for (var logger in _loggers) {
      logger.critical(object);
    }
  }

  Future<void> dispose(ServerContext context) async {
    for (var logger in _loggers) {
      await logger.dispose(context);
    }
  }
}
