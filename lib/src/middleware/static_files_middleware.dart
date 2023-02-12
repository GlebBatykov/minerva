part of minerva_middleware;

/// Middleware that is used to distribute static files.
class StaticFilesMiddleware extends Middleware {
  /// Path to the directory with static files.
  final String directory;

  /// The path that is used to access static files.
  final String path;

  /// The file that is used if the path to the file was not specified in the path.
  final String? root;

  late final String _directoryPath;

  StaticFilesMiddleware(
      {required this.directory, required this.path, this.root}) {
    _initialize();
  }

  void _initialize() {
    _directoryPath = '${HostEnvironment.contentRootPath}$directory';
  }

  @override
  Future<dynamic> handle(
      MiddlewareContext context, MiddlewarePipelineNode? next) async {
    final request = context.request;

    final requestPath = request.uri.path;

    if (requestPath.startsWith(path)) {
      final filePath = requestPath.substring(path.length, requestPath.length);

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
    if (filePath.isNotEmpty && filePath[0] != '/') {
      filePath = '/$filePath';
    }

    final file = File.fromUri(Uri.parse('$_directoryPath$filePath'));

    if (await file.exists()) {
      final bytes = await file.readAsBytes();

      final mimeType = lookupMimeType((basename(filePath))) ?? 'text/html';

      final mimeSegments = mimeType.split('/');

      final headers = MinervaHttpHeaders(
          contentLength: bytes.length,
          contentType: ContentType(mimeSegments.first, mimeSegments.last,
              charset: 'utf-8'));

      return Result(statusCode: 200, body: bytes, headers: headers);
    } else {
      return NotFoundResult();
    }
  }
}
