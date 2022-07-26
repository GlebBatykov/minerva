part of minerva_auth;

class AuthContext {
  final JwtAuthContext jwt = JwtAuthContext();

  final CookieAuthContext cookie = CookieAuthContext();
}
