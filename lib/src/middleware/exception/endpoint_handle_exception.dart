part of minerva_middleware;

class EndpointHandleException extends RequestHandleException {
  final MinervaRequest request;

  EndpointHandleException(super.error, super.stackTrace, this.request);
}
