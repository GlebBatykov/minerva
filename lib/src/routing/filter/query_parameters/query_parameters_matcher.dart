part of minerva_routing;

class QueryParametersMatcher {
  bool match(
      Map<String, String> queryParameters, QueryParametersFilter filter) {
    for (final parameter in filter.parameters) {
      if (!queryParameters.keys.contains(parameter.name)) {
        return false;
      }

      final value = queryParameters[parameter.name]!;

      if (parameter.type != null &&
          !_isParameterMatch(value, parameter.type!)) {
        return false;
      }
    }

    return true;
  }

  bool _isParameterMatch(String parameter, QueryParameterType type) {
    switch (type) {
      case QueryParameterType.int:
        return int.tryParse(parameter) != null;
      case QueryParameterType.double:
        return double.tryParse(parameter) != null &&
            int.tryParse(parameter) == null;
      case QueryParameterType.bool:
        return parameter == 'true' || parameter == 'false';
      case QueryParameterType.num:
        return num.tryParse(parameter) != null;
    }
  }
}
