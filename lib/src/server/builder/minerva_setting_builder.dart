part of minerva_server;

/// Used to configure the server.
abstract class MinervaSettingBuilder {
  FutureOr<MinervaSetting> build();
}
