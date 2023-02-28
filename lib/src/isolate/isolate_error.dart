part of minerva_isolate;

class IsolateError {
  final Object error;

  final StackTrace stackTrace;

  IsolateError(
    this.error,
    this.stackTrace,
  );
}
