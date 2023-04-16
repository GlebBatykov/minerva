part of minerva_routing;

class MinervaPath {
  final String path;

  final List<PathSegment> segments;

  final bool containsPathParameters;

  MinervaPath({
    required this.path,
    required this.segments,
    required this.containsPathParameters,
  });

  factory MinervaPath.parse(String path) {
    if (!path.startsWith('/')) {
      path = '/$path';
    }

    var containsPathParameters = false;

    final segments = <PathSegment>[];

    final pathSegments = path.split('/');

    pathSegments.removeWhere((e) => e.isEmpty);

    for (var i = 0; i < pathSegments.length; i++) {
      final segment = pathSegments[i];

      if (_isParameter(segment)) {
        segments.add(PathParameter.parse(segment));

        containsPathParameters = true;
      } else {
        segments.add(PathSegment(segment));
      }
    }

    return MinervaPath(
      path: path,
      segments: segments,
      containsPathParameters: containsPathParameters,
    );
  }

  static bool _isParameter(String segment) {
    return segment.contains(':');
  }
}
