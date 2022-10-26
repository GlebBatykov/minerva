part of minerva_auth;

/// JWT authorization options that the request must match.
class JwtAuthOptions {
  /// Roles that the endpoint has access to.
  final List<String>? roles;

  /// The permission level that the user must have in order to access the endpoint.
  final int? permissionLevel;

  const JwtAuthOptions({this.roles, this.permissionLevel});
}
