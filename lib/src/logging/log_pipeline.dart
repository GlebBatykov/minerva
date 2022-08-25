part of minerva_logging;

class LogPipeline {
  final List<Logger> _loggers;

  LogPipeline(List<Logger> loggers) : _loggers = loggers;

  Future<void> initialize(AgentConnectors connectors) async {
    for (var logger in _loggers) {
      await logger.initialize(connectors);
    }
  }

  Future<void> info(dynamic object) async {
    for (var logger in _loggers) {
      await logger.info(object);
    }
  }

  Future<void> debug(dynamic object) async {
    for (var logger in _loggers) {
      await logger.debug(object);
    }
  }

  Future<void> warning(dynamic object) async {
    for (var logger in _loggers) {
      await logger.warning(object);
    }
  }

  Future<void> error(dynamic object) async {
    for (var logger in _loggers) {
      await logger.error(object);
    }
  }

  Future<void> critical(dynamic object) async {
    for (var logger in _loggers) {
      await logger.critical(object);
    }
  }

  Future<void> dispose(AgentConnectors connectors) async {
    for (var logger in _loggers) {
      await logger.dispose();
    }
  }
}
