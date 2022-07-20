part of minerva_server;

abstract class Agent {
  FutureOr<void> initialize(Map<String, dynamic> data) {}

  FutureOr<dynamic> call(String action, Map<String, dynamic> data) {
    return null;
  }

  FutureOr<void> cast(String action, Map<String, dynamic> data) {}

  FutureOr<void> dispose() {}
}
