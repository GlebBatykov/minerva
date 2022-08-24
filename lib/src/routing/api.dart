part of minerva_routing;

abstract class Api {
  const Api();

  FutureOr<void> initialize(ServerContext context) {}

  FutureOr<void> build(Endpoints endpoints);

  FutureOr<void> dispose(ServerContext context) {}
}
