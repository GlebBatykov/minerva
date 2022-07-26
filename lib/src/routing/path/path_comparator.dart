part of minerva_routing;

class PathComparator {
  final bool parsePathParameters;

  PathComparator(this.parsePathParameters);

  PathCompareResult compare(String endpoint, String path) {
    if (parsePathParameters && endpoint.contains(':')) {
      var pathParameters = <String, num>{};

      var pathSegments = path.split('/');

      var endpointSegments = endpoint.split('/');

      pathSegments.removeWhere((element) => element.isEmpty);

      endpointSegments.removeWhere((element) => element.isEmpty);

      if (pathSegments.length != endpointSegments.length) {
        return PathCompareResult(false);
      }

      for (var i = 0; i < endpointSegments.length; i++) {
        var endpointSegment = endpointSegments[i];

        var pathSegment = pathSegments[i];

        if (_isParameter(endpointSegment)) {
          var parameter = PathParameter.parse(endpointSegment);

          if (_isMatch(parameter, pathSegment)) {
            late num value;

            if (parameter.type == PathParameterType.int) {
              value = int.parse(pathSegment);
            } else if (parameter.type == PathParameterType.double) {
              value = double.parse(pathSegment);
            } else {
              value = num.parse(pathSegment);
            }

            pathParameters[parameter.name] = value;
          } else {
            return PathCompareResult(false);
          }
        } else {
          if (pathSegment != endpointSegment) {
            return PathCompareResult(false);
          }
        }
      }

      return PathCompareResult(true, pathParameters);
    }

    return PathCompareResult(endpoint == path);
  }

  bool _isParameter(String segment) {
    return segment.contains(':');
  }

  bool _isMatch(PathParameter parameter, String segment) {
    var regExp = parameter.regExp;

    if (regExp != null && regExp.hasMatch(segment)) {
      return false;
    }

    if (parameter.type == PathParameterType.int) {
      return int.tryParse(segment) != null;
    } else if (parameter.type == PathParameterType.double) {
      return double.tryParse(segment) != null;
    } else {
      return num.tryParse(segment) != null;
    }
  }
}
