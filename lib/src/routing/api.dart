part of minerva_routing;

abstract class Api {
  FutureOr<void> initialize(ServerContext context) {}

  FutureOr<void> build(ServerContext context, Endpoints endpoints);

  FutureOr<void> dispose(ServerContext context) {}
}
