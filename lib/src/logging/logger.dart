part of minerva_logging;

/// Base class for logger classes.
abstract class Logger {
  /// The name of the logger. Each logger has unique name.
  final String name;

  final LoggingSetting _setting = LoggingSetting();

  Logger({required this.name});

  /// Initialization of the logger before starting work.
  ///
  /// This method is needed to initialize the resources necessary for operation, after the logger hits the server instance in which it will be used.
  FutureOr<void> initialize(AgentConnectors connectors) {}

  /// Checks whether [level] is enabled for this logger.
  bool isLevelEnabled(LogLevel level) {
    return _setting.isLevelEnabled(name, level);
  }

  /// Log [object] with info log level.
  FutureOr<void> info(dynamic object);

  /// Log [object] with debug log level.
  FutureOr<void> debug(dynamic object);

  /// Log [object] with warning log level.
  FutureOr<void> warning(dynamic object);

  /// Log [object] with error log level.
  FutureOr<void> error(dynamic object);

  /// Log [object] with critical log level.
  FutureOr<void> critical(dynamic object);

  /// The method is necessary to free up resources.
  ///
  /// You may need it if you decided to shut down the server yourself for some reason and used the dispose method of the Minerva class.
  FutureOr<void> dispose() {}
}
