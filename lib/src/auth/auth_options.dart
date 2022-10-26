part of minerva_auth;

/// Authentication options that are used to access endpoints or redirects.
class AuthOptions {
  /// JWT authentication options.
  final JwtAuthOptions? jwt;

  /// Cookie authentication options.
  final CookieAuthOptions? cookie;

  const AuthOptions({this.jwt, this.cookie});
}
