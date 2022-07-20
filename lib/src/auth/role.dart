part of minerva_auth;

class Role {
  final String name;

  final int? permissionLevel;

  Role(this.name, {this.permissionLevel});
}
