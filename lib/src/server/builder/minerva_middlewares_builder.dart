part of minerva_server;

/// Used to configure the middlewares on the server.
abstract class MinervaMiddlewaresBuilder {
  FutureOr<List<Middleware>> build();
}
