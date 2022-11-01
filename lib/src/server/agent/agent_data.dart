part of minerva_server;

/// Used to create agents during server initialization.
class AgentData {
  /// The agent's name, it must be unique.
  final String name;

  /// The agent that will be launched.
  final Agent agent;

  /// Data that will be passed to the agent when the initialize() method is called.
  final Map<String, dynamic>? data;

  const AgentData(this.name, this.agent, {this.data});
}
