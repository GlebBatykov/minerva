part of minerva_logging;

class LogLevelMiddleware extends LoggerMiddleware {
  @override
  Log handle(Log log) {
    log.template = log.template.replaceAll('&level', log.level.name);

    return log;
  }
}
