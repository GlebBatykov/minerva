part of minerva_server;

class EndpointHandleException extends RequestHandleException {
  final MinervaRequest request;

  EndpointHandleException(super.error, super.stackTrace, this.request,
      {super.message});
}
