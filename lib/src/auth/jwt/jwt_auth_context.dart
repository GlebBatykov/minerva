part of minerva_auth;

/// Contains JWT authentication request data.
class JwtAuthContext {
  /// JWT token.
  final String token;

  /// Role of the user.
  Role? role;

  JwtAuthContext({required this.token, this.role});
}
