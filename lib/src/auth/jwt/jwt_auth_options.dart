part of minerva_auth;

class JwtAuthOptions {
  final List<String>? roles;

  final int? permissionLevel;

  JwtAuthOptions({this.roles, this.permissionLevel});
}
