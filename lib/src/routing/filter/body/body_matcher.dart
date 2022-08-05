part of minerva_routing;

class BodyMatcher {
  Future<bool> match(MinervaRequest request, BodyFilter filter) async {
    if (request.headers.contentType == null) {
      return false;
    }

    if (filter is JsonFilter) {
      return await _matchJson(request, filter);
    } else if (filter is FormFilter) {
      return await _matchForm(request, filter);
    } else {
      return false;
    }
  }

  Future<bool> _matchJson(MinervaRequest request, JsonFilter filter) async {
    if (request.headers.contentType!.mimeType != 'application/json') {
      return false;
    }

    late Map<String, dynamic> json;

    try {
      json = await request.body.asJson();
    } catch (_) {
      return false;
    }

    for (var field in filter.fields) {
      if (!json.keys.contains(field.name)) {
        return false;
      }

      var value = json[field.name];

      if (field.type != null && !_isJsonFieldMatch(value, field.type!)) {
        return false;
      }
    }

    return true;
  }

  bool _isJsonFieldMatch(dynamic value, JsonFieldType type) {
    switch (type) {
      case JsonFieldType.int:
        return value is int;
      case JsonFieldType.double:
        return value is double;
      case JsonFieldType.string:
        return value is String;
      case JsonFieldType.bool:
        return value is bool;
      case JsonFieldType.map:
        return value is Map;
      case JsonFieldType.list:
        return value is List;
    }
  }

  Future<bool> _matchForm(MinervaRequest request, FormFilter filter) async {
    if (request.headers.contentType!.mimeType != 'multipart/form-data') {
      return false;
    }

    late FormData formData;

    try {
      formData = await request.body.asForm();
    } catch (_) {
      return false;
    }

    for (var field in filter.fields) {
      if (!formData.data.keys.contains(field.name)) {
        return false;
      }

      var value = formData[field.name]!;

      if (field.type != null && !_isFormFieldMatch(value, field.type!)) {
        return false;
      }
    }

    return true;
  }

  bool _isFormFieldMatch(FormDataValue value, FormFieldType type) {
    switch (type) {
      case FormFieldType.string:
        return value is FormDataString;
      case FormFieldType.file:
        return value is FormDataFile;
    }
  }
}
