part of minerva_cli;

class AssetsFilesParser {
  final String _projectPath;

  final List<File> _files = [];

  AssetsFilesParser(String projectPath) : _projectPath = projectPath;

  Future<List<File>> parse(List<String> assets) async {
    _files.clear();

    for (var asset in assets) {
      if (asset[0] == '/') {
        var directoryPath = '$_projectPath$asset';

        var directory = Directory.fromUri(
            Uri.directory(directoryPath, windows: Platform.isWindows));

        if (!await directory.exists()) {
          throw CLICommandException(
              message:
                  'The directory along the path $directoryPath does not exist');
        }

        await _decomposeFileSystemEntry(directory);
      } else {
        var filePath = '$_projectPath/$asset';

        var file =
            File.fromUri(Uri.file(filePath, windows: Platform.isWindows));

        if (!await file.exists()) {
          throw CLICommandException(
              message: 'The file along the path $filePath does not exist');
        }

        _files.add(file);
      }
    }

    return _files;
  }

  Future<void> _decomposeFileSystemEntry(FileSystemEntity entity) async {
    if (entity is File) {
      _files.add(entity);
    } else if (entity is Directory) {
      for (var child in await entity.list().toList()) {
        await _decomposeFileSystemEntry(child);
      }
    }
  }
}
