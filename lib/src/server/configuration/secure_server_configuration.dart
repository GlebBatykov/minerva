part of minerva_server;

class SecureServerConfiguration extends ServerConfiguration {
  final SecurityContext securityContext;

  final bool requestClientCertificate;

  SecureServerConfiguration({
    required this.securityContext,
    this.requestClientCertificate = false,
    super.sessionTimeout,
    super.backlog,
    super.v6Only,
  });
}
