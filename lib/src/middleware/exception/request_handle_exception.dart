part of minerva_middleware;

class RequestHandleException extends MinervaException {
  final Object error;

  final StackTrace stackTrace;

  RequestHandleException(this.error, this.stackTrace);

  @override
  String toString() {
    return '$error\n$stackTrace';
  }
}
