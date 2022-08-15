part of minerva_auth;

class AuthOptions {
  final JwtAuthOptions? jwt;

  final CookieAuthOptions? cookie;

  const AuthOptions({this.jwt, this.cookie});
}
