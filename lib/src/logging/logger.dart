part of minerva_logging;

abstract class Logger {
  final String name;

  final LoggingSetting _setting = LoggingSetting();

  Logger(this.name);

  FutureOr<void> initialize(AgentConnectors connectors) {}

  bool isLevelEnabled(LogLevel level) {
    return _setting.isLevelEnabled(name, level);
  }

  FutureOr<void> info(dynamic object);

  FutureOr<void> debug(dynamic object);

  FutureOr<void> warning(dynamic object);

  FutureOr<void> error(dynamic object);

  FutureOr<void> critical(dynamic object);

  FutureOr<void> dispose(ServerContext context) {}
}
