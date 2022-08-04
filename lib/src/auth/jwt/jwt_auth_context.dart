part of minerva_auth;

class JwtAuthContext {
  final String token;

  Role? role;

  JwtAuthContext({required this.token, this.role});
}
