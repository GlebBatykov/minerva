part of minerva_server;

abstract class MinervaServerBuilder {
  FutureOr<void> build(ServerContext context);
}
