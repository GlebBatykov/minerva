part of minerva_logging;

abstract class LoggerMiddleware {
  const LoggerMiddleware();

  Log handle(Log log);
}
