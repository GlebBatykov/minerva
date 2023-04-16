part of minerva_server;

abstract class AgentAction {}

class AgentInitialize extends AgentAction {
  final Map<String, Object?> data;

  AgentInitialize(this.data);
}

class AgentCall extends AgentAction {
  final String action;

  final Map<String, Object?> data;

  final SendPort feedbackPort;

  AgentCall({
    required this.action,
    required this.data,
    required this.feedbackPort,
  });
}

class AgentCast extends AgentAction {
  final String action;

  final Map<String, Object?> data;

  AgentCast(this.action, this.data);
}

class AgentDispose extends AgentAction {}
