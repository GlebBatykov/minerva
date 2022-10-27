part of minerva_server;

/// Used to configure the apis on the server.
abstract class MinervaApisBuilder {
  FutureOr<List<Api>> build();
}
