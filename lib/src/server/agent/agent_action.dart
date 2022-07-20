part of minerva_server;

abstract class AgentAction {}

class AgentInitialize extends AgentAction {
  final Map<String, dynamic> data;

  AgentInitialize(this.data);
}

class AgentCall extends AgentAction {
  final String action;

  final Map<String, dynamic> data;

  final SendPort feedbackPort;

  AgentCall(this.action, this.data, this.feedbackPort);
}

class AgentCast extends AgentAction {
  final String action;

  final Map<String, dynamic> data;

  AgentCast(this.action, this.data);
}

class AgentDispose extends AgentAction {}
