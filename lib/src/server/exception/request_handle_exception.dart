part of minerva_server;

class RequestHandleException extends MinervaException {
  final Object error;

  final StackTrace stackTrace;

  RequestHandleException(this.error, this.stackTrace, {required String message})
      : super(message);

  @override
  String toString() {
    return '${error.runtimeType}\n$stackTrace';
  }
}
