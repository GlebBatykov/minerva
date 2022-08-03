part of minerva_middleware;

class RedirectionLocation {
  final Uri uri;

  late final MinervaPath path;

  RedirectionLocation(String location) : uri = Uri.parse(location) {
    path = MinervaPath.parse(uri.path);
  }

  @override
  String toString() {
    return '${uri.origin}${path.path}';
  }
}
