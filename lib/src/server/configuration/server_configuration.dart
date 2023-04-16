part of minerva_server;

class ServerConfiguration {
  final int? sessionTimeout;

  final int backlog;

  final bool v6Only;

  ServerConfiguration({
    this.sessionTimeout,
    this.backlog = 0,
    this.v6Only = false,
  });
}
