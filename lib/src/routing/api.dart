part of minerva_routing;

/// An arbitrary class for all Apis.
///
/// Apis are multiple endpoints that have some kind of common context.
abstract class Api {
  const Api();

  /// Initialization of the api before starting work.
  ///
  /// This method is needed to initialize the resources necessary for operation, after the api hits the server instance in which it will be used.
  FutureOr<void> initialize(ServerContext context) {}

  /// Used to create endpoints.
  FutureOr<void> build(Endpoints endpoints);

  /// The method is necessary to free up resources.
  ///
  /// You may need it if you decided to shut down the server yourself for some reason and used the dispose method of the Minerva class.
  FutureOr<void> dispose(ServerContext context) {}
}
