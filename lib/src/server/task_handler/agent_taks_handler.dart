part of minerva_server;

class AgentTaskHandler extends IsolateTaskHandler {
  late final Agent _agent;

  @override
  Future<void> onStart(IsolateContext context) async {
    _agent = context.data['agent'];

    _agent.initialize(context.data['data']);

    context.receive<AgentCall>(_handleAgentCall);

    context.receive<AgentCast>(_handleAgentCast);
  }

  void _handleAgentCall(AgentCall action) async {
    var result = await _agent.call(action.action, action.data);

    action.feedbackPort.send(AgentCallResult(result));
  }

  void _handleAgentCast(AgentCast action) {
    _agent.cast(action.action, action.data);
  }
}
