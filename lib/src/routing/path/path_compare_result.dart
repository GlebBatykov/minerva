part of minerva_routing;

class PathCompareResult {
  final bool isEqual;

  final Map<String, num>? pathParameters;

  PathCompareResult(this.isEqual, [this.pathParameters]);
}
