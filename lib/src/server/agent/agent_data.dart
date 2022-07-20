part of minerva_server;

class AgentData {
  final String name;

  final Agent agent;

  final Map<String, dynamic>? data;

  AgentData(this.name, this.agent, {this.data});
}
