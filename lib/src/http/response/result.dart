part of minerva_http;

class Result {
  final int statusCode;

  final dynamic body;

  final MinervaHttpHeaders? headers;

  FutureOr<MinervaResponse> get response async {
    return MinervaResponse(
        statusCode: statusCode, body: body, headers: headers);
  }

  Result({required this.statusCode, this.body, this.headers});
}

class OkResult extends Result {
  OkResult({super.body, super.headers}) : super(statusCode: 200);
}

class BadRequestResult extends Result {
  BadRequestResult({super.body, super.headers}) : super(statusCode: 400);
}

class UnauthorizedResult extends Result {
  UnauthorizedResult({super.body, super.headers}) : super(statusCode: 401);
}

class InternalServerErrorResult extends Result {
  InternalServerErrorResult({super.body, super.headers})
      : super(statusCode: 500);
}

class JsonResult extends Result {
  JsonResult(Map<String, dynamic> json, {int? statusCode, super.headers})
      : super(statusCode: statusCode ?? 200, body: jsonEncode(json));
}

class NotFoundResult extends Result {
  NotFoundResult({super.body, super.headers}) : super(statusCode: 404);
}

class FileResult extends Result {
  final File file;

  final String? name;

  FileResult(this.file, {this.name, super.headers}) : super(statusCode: 200);

  @override
  Future<MinervaResponse> get response async {
    var body = await file.readAsBytes();

    var headers = MinervaHttpHeaders();

    var header = 'attachment';

    if (name != null) {
      header += '; filename="$name"';
    }

    headers['Content-Disposition'] = header;

    return MinervaResponse(
        statusCode: statusCode, body: body, headers: headers);
  }
}

class FilePathResult extends FileResult {
  FilePathResult(String path, {super.name, super.headers})
      : super(File.fromUri(Uri.file(FilePathParser.parse(path))));
}

class FileContentResult extends Result {
  final File file;

  FileContentResult(this.file, {super.headers}) : super(statusCode: 200);

  @override
  Future<MinervaResponse> get response async {
    var body = await file.readAsString();

    return MinervaResponse(statusCode: statusCode, body: body);
  }
}

class FilePathContentResult extends FileContentResult {
  FilePathContentResult(String path, {super.headers})
      : super(File.fromUri(Uri.file(FilePathParser.parse(path))));
}
