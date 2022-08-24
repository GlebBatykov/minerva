part of minerva_auth;

class Role {
  final String name;

  final int? permissionLevel;

  const Role(this.name, {this.permissionLevel});
}
