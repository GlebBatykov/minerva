part of minerva_server;

abstract class AgentEvent {}

class AgentInitialized extends AgentEvent {}

class AgentCallResult extends AgentEvent {
  final dynamic result;

  AgentCallResult(this.result);
}

class AgentDisposed extends AgentEvent {}
