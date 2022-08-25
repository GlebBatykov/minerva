part of minerva_server;

class AgentTaskHandler extends IsolateTaskHandler {
  final Agent _agent;

  final Map<String, dynamic> _data;

  AgentTaskHandler(Agent agent, Map<String, dynamic> data)
      : _agent = agent,
        _data = data;

  @override
  Future<void> onStart(IsolateContext context) async {
    await _agent.initialize(_data);

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

  @override
  Future<void> onDispose(IsolateContext context) async {
    await _agent.dispose();
  }
}
