part of minerva_server;

/// Used to configure the server.
///
/// Here you can prescribe the logic of dependency injection.
abstract class MinervaServerBuilder {
  FutureOr<void> build(ServerContext context);
}
