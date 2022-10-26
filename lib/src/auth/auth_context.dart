part of minerva_auth;

/// Represents the authentication context of an incoming request.
class AuthContext {
  /// JWT authentication context of an incoming request.
  JwtAuthContext? jwt;

  /// Cookie authentication context of an incoming request.
  CookieAuthContext? cookie;
}
