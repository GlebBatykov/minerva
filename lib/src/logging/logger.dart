part of minerva_logging;

abstract class Logger {
  FutureOr<void> initialize(ServerContext context) {}

  void info(dynamic object);

  void debug(dynamic object);

  void warning(dynamic object);

  void error(dynamic object);

  void critical(dynamic object);

  FutureOr<void> dispose(ServerContext context) {}
}
