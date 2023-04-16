part of minerva_logging;

class LogLevelMiddleware extends LoggerMiddleware {
  const LogLevelMiddleware();

  @override
  Log handle(Log log) {
    log.template = log.template.replaceAll('&level', log.level.name);

    return log;
  }
}
