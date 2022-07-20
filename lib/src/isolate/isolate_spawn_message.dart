part of minerva_isolate;

class IsolateSpawnMessage {
  final SendPort supervisorPort;

  IsolateSpawnMessage(this.supervisorPort);
}
