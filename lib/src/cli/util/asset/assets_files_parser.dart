part of minerva_cli;

class AssetsFilesParser {
  final String _projectPath;

  final List<File> _files = [];

  AssetsFilesParser(String projectPath) : _projectPath = projectPath;

  Future<List<File>> parseMany(List<String> assets) async {
    _files.clear();

    for (final asset in assets) {
      await _parceAsset(asset);
    }

    return _files;
  }

  Future<List<File>> parseOne(String asset) async {
    _files.clear();

    await _parceAsset(asset);

    return _files;
  }

  Future<void> _parceAsset(String asset) async {
    if (asset[0] == '/') {
      final directoryPath = '$_projectPath$asset';

      final directory = Directory.fromUri(
          Uri.directory(directoryPath, windows: Platform.isWindows));

      if (!await directory.exists()) {
        throw CLICommandException(
            message:
                'The directory along the path $directoryPath does not exist');
      }

      await _decomposeFileSystemEntry(directory);
    } else {
      final filePath = '$_projectPath/$asset';

      final file =
          File.fromUri(Uri.file(filePath, windows: Platform.isWindows));

      if (!await file.exists()) {
        throw CLICommandException(
            message: 'The file along the path $filePath does not exist');
      }

      _files.add(file);
    }
  }

  Future<void> _decomposeFileSystemEntry(FileSystemEntity entity) async {
    if (entity is File) {
      _files.add(entity);
    } else if (entity is Directory) {
      for (final child in await entity.list().toList()) {
        await _decomposeFileSystemEntry(child);
      }
    }
  }
}
