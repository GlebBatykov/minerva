part of minerva_isolate;

abstract class IsolateAction {}

class IsolateStart extends IsolateAction {
  final IsolateTaskHandler handler;

  final Map<String, dynamic> data;

  IsolateStart(this.handler, this.data);
}

class IsolateStop extends IsolateAction {}

class IsolateResume extends IsolateAction {}

class IsolatePause extends IsolateAction {}
