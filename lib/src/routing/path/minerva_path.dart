part of minerva_routing;

class MinervaPath {
  final String path;

  final List<PathSegment> segments;

  final bool containsPathParameters;

  MinervaPath(this.path, this.segments, this.containsPathParameters);

  factory MinervaPath.parse(String path) {
    var containsPathParameters = false;

    var segments = <PathSegment>[];

    var pathSegments = path.split('/');

    pathSegments.removeWhere((element) => element.isEmpty);

    for (var segment in pathSegments) {
      if (_isParameter(segment)) {
        segments.add(PathParameter.parse(segment));

        containsPathParameters = true;
      } else {
        segments.add(PathSegment(segment));
      }
    }

    return MinervaPath(path, segments, containsPathParameters);
  }

  static bool _isParameter(String segment) {
    return segment.contains(':');
  }
}
