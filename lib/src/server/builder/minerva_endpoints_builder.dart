part of minerva_server;

/// Used to configure endpoints on the server.
abstract class MinervaEndpointsBuilder {
  FutureOr<void> build(Endpoints endpoints);
}
