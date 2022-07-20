part of minerva_isolate;

abstract class IsolateTaskHandler {
  FutureOr<void> onStart(IsolateContext context) {}

  FutureOr<void> onStop(IsolateContext context) {}

  FutureOr<void> onPause(IsolateContext context) {}

  FutureOr<void> onResume(IsolateContext context) {}
}
