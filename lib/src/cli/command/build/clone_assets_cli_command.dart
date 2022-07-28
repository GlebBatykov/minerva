part of minerva_cli;

class CloneAssetsCLICommand extends CLICommand<List<FileLog>> {
  final String projectPath;

  final String mode;

  final Map<String, dynamic> appSetting;

  final List<File> _files = [];

  CloneAssetsCLICommand(this.projectPath, this.mode, this.appSetting);

  @override
  Future<List<FileLog>> run() async {
    var fileLogs = <FileLog>[];

    late List<String> assets;

    try {
      assets = AppSettingAssetsParser().parse(appSetting);
    } catch (_) {
      return fileLogs;
    }

    _files.clear();

    await _setFiles(assets);

    await _cloneFiles();

    fileLogs.addAll(await _createFileLogs());

    return fileLogs;
  }

  Future<void> _setFiles(List<String> assets) async {
    for (var asset in assets) {
      if (asset[0] == '/') {
        var directoryPath = '$projectPath$asset';

        var directory = Directory.fromUri(Uri.directory(directoryPath));

        if (!await directory.exists()) {
          throw CLICommandException(
              message:
                  'The directory along the path $directoryPath does not exist');
        }

        await _decomposeFileSystemEntry(directory);
      } else {
        var filePath = '$projectPath/$asset';

        var file = File.fromUri(Uri.file(filePath));

        if (!await file.exists()) {
          throw CLICommandException(
              message: 'The file along the path $filePath does not exist');
        }

        _files.add(file);
      }
    }
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

  Future<List<FileLog>> _createFileLogs() async {
    var fileLogs = <FileLog>[];

    for (var file in _files) {
      var stat = await file.stat();

      fileLogs.add(FileLog(FileLogType.asset, file.path, stat.modified));
    }

    return fileLogs;
  }

  Future<void> _cloneFiles() async {
    for (var file in _files) {
      var relativePath =
          file.path.substring(projectPath.length, file.path.length);

      var buildFilePath = '$projectPath/build/$mode$relativePath';

      var buildFile = File.fromUri(Uri.file(buildFilePath));

      await buildFile.create(recursive: true);

      await buildFile.writeAsBytes(await file.readAsBytes());
    }
  }
}
