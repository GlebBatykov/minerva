part of minerva_server;

/// Used to configure the loggers on the server.
abstract class MinervaLoggersBuilder {
  FutureOr<List<Logger>> build();
}
