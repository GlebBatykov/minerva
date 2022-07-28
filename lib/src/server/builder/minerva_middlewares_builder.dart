part of minerva_server;

abstract class MinervaMiddlewaresBuilder {
  FutureOr<List<Middleware>> build();
}
