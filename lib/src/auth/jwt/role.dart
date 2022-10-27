part of minerva_auth;

/// Used for JWT user authentication.
class Role {
  /// Name of user role.
  final String name;

  /// Permission level of user.
  ///
  /// The permission level that the user must have in order to access the endpoint.
  final int? permissionLevel;

  const Role(this.name, {this.permissionLevel});
}
