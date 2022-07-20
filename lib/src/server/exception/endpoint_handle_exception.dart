part of minerva_server;

class EndpointHandleException extends MinervaException {
  final Object error;

  final StackTrace stackTrace;

  final MinervaRequest request;

  EndpointHandleException(this.error, this.stackTrace, this.request,
      {String? message})
      : super(message);

  @override
  String toString() {
    return '${error.runtimeType}\n$stackTrace';
  }
}
