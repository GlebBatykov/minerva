part of minerva_middleware;

class EndpointHandleException extends RequestHandleException {
  final MinervaRequest request;

  EndpointHandleException({
    required Object error,
    required StackTrace stackTrace,
    required this.request,
  }) : super(error, stackTrace);
}
