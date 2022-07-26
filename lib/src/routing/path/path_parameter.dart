part of minerva_routing;

class PathParameter {
  final PathParameterType type;

  final String name;

  final RegExp? regExp;

  PathParameter(this.type, this.name, [this.regExp]);

  factory PathParameter.parse(String segment) {
    late PathParameterType type;

    late String name;

    RegExp? regExp;

    if (segment.startsWith('int')) {
      type = PathParameterType.int;
    } else if (segment.startsWith('double')) {
      type = PathParameterType.double;
    } else {
      type = PathParameterType.num;
    }

    if (type == PathParameterType.int || type == PathParameterType.double) {
      if (segment.contains('(') && segment.contains(')')) {
        var startRegExp = segment.indexOf('(');

        var endRegExp = segment.indexOf(')');

        name = segment.substring(type.name.length + 1, startRegExp - 1);

        regExp = RegExp(segment.substring(startRegExp, endRegExp + 1));
      } else {
        name = segment.substring(type.name.length + 1, segment.length);
      }
    } else {
      if (segment.contains('(') && segment.contains(')')) {
        var startRegExp = segment.indexOf('(');

        var endRegExp = segment.indexOf(')');

        name = segment.substring(1, startRegExp);

        regExp = RegExp(segment.substring(startRegExp, endRegExp + 1));
      } else {
        var start = segment.indexOf(':');

        name = segment.substring(start + 1, segment.length);
      }
    }

    return PathParameter(type, name, regExp);
  }
}
