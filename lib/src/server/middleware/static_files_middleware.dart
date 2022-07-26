part of minerva_server;

class StaticFilesMiddleware extends Middleware {
  final String directory;

  final String path;

  final String? root;

  late final String _directoryPath;

  StaticFilesMiddleware(
      {required this.directory, required this.path, this.root}) {
    _initialize();
  }

  void _initialize() {
    _directoryPath = '/${Project.projectPath}$directory';
  }

  @override
  Future<dynamic> handle(MiddlewareContext context, PipelineNode? next) async {
    var request = context.request;

    var requestPath = request.uri.path;

    if (requestPath.startsWith(path)) {
      var filePath = requestPath.substring(path.length, requestPath.length);

      if (filePath != '/' && filePath.isNotEmpty) {
        return _handleFile(filePath);
      } else {
        if (root != null) {
          return _handleFile(root!);
        } else {
          return NotFoundResult();
        }
      }
    }

    if (next != null) {
      return await next.handle(context);
    } else {
      return NotFoundResult();
    }
  }

  Future<Result> _handleFile(String filePath) async {
    print(filePath);

    if (filePath.isNotEmpty && filePath[0] != '/') {
      filePath = '/$filePath';
    }

    var file = File.fromUri(Uri.file('$_directoryPath$filePath'));

    print(file.path);

    if (await file.exists()) {
      var bytes = await file.readAsBytes();

      var mimeType = mime(basename(filePath)) ?? 'text/html';

      var mimeSegments = mimeType.split('/');

      var headers = MinervaHttpHeaders(
          contentLength: bytes.length,
          contentType: ContentType(mimeSegments.first, mimeSegments.last,
              charset: 'utf-8'));

      return Result(statusCode: 200, body: bytes, headers: headers);
    } else {
      return NotFoundResult();
    }
  }
}
