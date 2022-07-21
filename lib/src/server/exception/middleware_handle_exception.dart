part of minerva_server;

class MiddlewareHandleException extends RequestHandleException {
  MiddlewareHandleException(super.error, super.stackTrace, {super.message});
}
