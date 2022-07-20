part of minerva_auth;

class AuthOptions {
  final List<String>? roles;

  final int? permissionLevel;

  AuthOptions({this.roles, this.permissionLevel});
}
