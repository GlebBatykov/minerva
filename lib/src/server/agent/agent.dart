part of minerva_server;

/// The base class for all agent classes.
///
/// Agent is an entity that is executed in a separate isolate.
///
/// All server instances can access it using connectors.
abstract class Agent {
  /// Used for initializing resources.
  ///
  /// Called when the agent has been transferred to the isolate where it will work.
  FutureOr<void> initialize(Map<String, dynamic> data) {}

  ///Processing a request from some server instance.
  ///
  /// This type of request must have a response.
  ///
  /// Action is needed in order to differentiate incoming requests.
  ///
  /// Data contains some data that the server instance can pass to the agent.
  FutureOr<dynamic> call(String action, Map<String, dynamic> data) {
    return null;
  }

  /// Processing a request from some server instance.
  ///
  /// This type of request does not send a response.
  ///
  /// Action is needed in order to differentiate incoming requests.
  ///
  /// Data contains some data that the server instance can pass to the agent.
  FutureOr<void> cast(String action, Map<String, dynamic> data) {}

  /// The method is necessary to free up resources.
  ///
  /// You may need it if you decided to shut down the server yourself for some reason and used the dispose method of the Minerva class.
  FutureOr<void> dispose() {}
}
