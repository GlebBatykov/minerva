part of minerva_http;

class Result {
  final int statusCode;

  final Object? body;

  final MinervaHttpHeaders? headers;

  FutureOr<MinervaResponse> get response async {
    return MinervaResponse(
      statusCode: statusCode,
      body: body,
      headers: headers,
    );
  }

  const Result({
    required this.statusCode,
    this.body,
    this.headers,
  });
}

class OkResult extends Result {
  const OkResult({
    super.body,
    super.headers,
  }) : super(statusCode: 200);
}

class BadRequestResult extends Result {
  const BadRequestResult({
    super.body,
    super.headers,
  }) : super(statusCode: 400);
}

class UnauthorizedResult extends Result {
  const UnauthorizedResult({
    super.body,
    super.headers,
  }) : super(statusCode: 401);
}

class InternalServerErrorResult extends Result {
  const InternalServerErrorResult({
    super.body,
    super.headers,
  }) : super(statusCode: 500);
}

class JsonResult extends Result {
  JsonResult(
    Object? json, {
    int? statusCode,
    super.headers,
  }) : super(
          statusCode: statusCode ?? 200,
          body: jsonEncode(json),
        );

  @override
  Future<MinervaResponse> get response async {
    final minervaHeaders = headers ?? MinervaHttpHeaders();

    minervaHeaders.contentType = ContentType.json;

    return MinervaResponse(
        statusCode: statusCode, body: body, headers: minervaHeaders);
  }
}

class NotFoundResult extends Result {
  const NotFoundResult({
    super.body,
    super.headers,
  }) : super(statusCode: 404);
}

class FileResult extends Result {
  final File file;

  final String? name;

  FileResult(
    this.file, {
    this.name,
    super.headers,
  }) : super(statusCode: 200);

  @override
  Future<MinervaResponse> get response async {
    final body = await file.readAsBytes();

    final headers = MinervaHttpHeaders();

    var header = 'attachment';

    late String fileName;

    if (name != null) {
      fileName = name!;
    } else {
      fileName = basename(file.absolute.path);
    }

    header += '; filename="$fileName"';

    headers['Content-Disposition'] = header;

    return MinervaResponse(
      statusCode: statusCode,
      body: body,
      headers: headers,
    );
  }
}

class FilePathResult extends FileResult {
  FilePathResult(
    String path, {
    super.name,
    super.headers,
  }) : super(File.fromUri(Uri.file(FilePathParser.parse(path))));
}

class FileContentResult extends Result {
  final File file;

  FileContentResult(
    this.file, {
    super.headers,
  }) : super(statusCode: 200);

  @override
  Future<MinervaResponse> get response async {
    final body = await file.readAsString();

    return MinervaResponse(
      statusCode: statusCode,
      body: body,
    );
  }
}

class FilePathContentResult extends FileContentResult {
  FilePathContentResult(
    String path, {
    super.headers,
  }) : super(File.fromUri(Uri.file(FilePathParser.parse(path))));
}

class RedirectionResult extends Result {
  RedirectionResult(String location)
      : super(
          statusCode: 301,
          headers: MinervaHttpHeaders(
            headers: {
              HttpHeaders.locationHeader: location,
            },
          ),
        );
}
