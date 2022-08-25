part of minerva_isolate;

abstract class IsolateEvent {}

class IsolateInitialized extends IsolateEvent {
  final SendPort isolatePort;

  IsolateInitialized(this.isolatePort);
}

class IsolateStarted extends IsolateEvent {}

class IsolateStoped extends IsolateEvent {}

class IsolateResumed extends IsolateEvent {}

class IsolatePaused extends IsolateEvent {}

class IsolateDisposed extends IsolateEvent {}
