part of minerva_routing;

class PathComparator {
  PathCompareResult compare(MinervaPath minervaPath, String path) {
    if (minervaPath.containsPathParameters) {
      final pathParameters = <String, num>{};

      final pathSegments = path.split('/');

      pathSegments.removeWhere((element) => element.isEmpty);

      final endpointSegments = minervaPath.segments;

      if (pathSegments.length != endpointSegments.length) {
        return PathCompareResult(false);
      }

      for (var i = 0; i < endpointSegments.length; i++) {
        final endpointSegment = endpointSegments[i];

        final pathSegment = pathSegments[i];

        if (endpointSegment is PathParameter) {
          if (_isMatch(endpointSegment, pathSegment)) {
            late num value;

            if (endpointSegment.type == PathParameterType.int) {
              value = int.parse(pathSegment);
            } else if (endpointSegment.type == PathParameterType.double) {
              value = double.parse(pathSegment);
            } else {
              value = num.parse(pathSegment);
            }

            pathParameters[endpointSegment.value] = value;
          } else {
            return PathCompareResult(false);
          }
        } else {
          if (pathSegment != endpointSegment.value) {
            return PathCompareResult(false);
          }
        }
      }

      return PathCompareResult(true, pathParameters);
    }

    return PathCompareResult(minervaPath.path == path);
  }

  bool _isMatch(PathParameter parameter, String segment) {
    final regExp = parameter.regExp;

    if (regExp != null && regExp.hasMatch(segment)) {
      return false;
    }

    if (parameter.type == PathParameterType.int) {
      return int.tryParse(segment) != null;
    } else if (parameter.type == PathParameterType.double) {
      return int.tryParse(segment) == null && double.tryParse(segment) != null;
    } else {
      return num.tryParse(segment) != null;
    }
  }
}
