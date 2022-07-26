part of minerva_server;

class StaticFilesMiddleware extends Middleware {
  final String directory;

  final String path;

  late final String _directoryPath;

  StaticFilesMiddleware({required this.directory, required this.path}) {
    _initialize();
  }

  void _initialize() {
    var scriptPath = Uri.directory(Platform.script.path);

    _directoryPath =
        '/${scriptPath.pathSegments.getRange(0, scriptPath.pathSegments.length - 3).join('/')}$directory';
  }

  @override
  Future<dynamic> handle(MiddlewareContext context, PipelineNode? next) async {
    var request = context.request;

    var requestPath = request.uri.path;

    if (requestPath.startsWith(path)) {
      var filePath = requestPath.substring(path.length, requestPath.length);

      var file = File.fromUri(Uri.file('$_directoryPath$filePath'));

      print(filePath);

      print(file.path);

      if (await file.exists()) {
        var body = await file.readAsBytes();

        var headers = MinervaHttpHeaders();

        var mimeType = mime(basename(filePath));

        print(mimeType);

        headers['Content-Type'] = mimeType ?? 'text/html';

        return Result(statusCode: 200, body: body, headers: headers);
      } else {
        return NotFoundResult();
      }
    }

    if (next != null) {
      return await next.handle(context);
    } else {
      return NotFoundResult();
    }
  }
}
