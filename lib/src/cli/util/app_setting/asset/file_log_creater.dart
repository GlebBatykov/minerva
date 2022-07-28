part of minerva_cli;

class FileLogCreater {
  final String _projectPath;

  FileLogCreater(String projectPath) : _projectPath = projectPath;

  Future<List<FileLog>> createAssetsLogs(List<File> assets) async {
    var fileLogs = <FileLog>[];

    for (var file in assets) {
      fileLogs.add(await createAssetLog(file));
    }

    return fileLogs;
  }

  Future<FileLog> createAssetLog(File file) async {
    var stat = await file.stat();

    var relativePath = relative(file.path, from: _projectPath);

    return FileLog(FileLogType.asset, relativePath, stat.modified);
  }

  Future<FileLog> createAppSettingLog(File file) async {
    var appSettingFileStat = await file.stat();

    var modificationTime = appSettingFileStat.modified;

    var relativePath = relative(file.path, from: _projectPath);

    var fileLog =
        FileLog(FileLogType.appsetting, relativePath, modificationTime);

    return fileLog;
  }

  Future<List<FileLog>> createSourceLogs(Directory libDirectory) async {
    var fileLogs = <FileLog>[];

    for (var entity in await libDirectory.list(recursive: true).toList()) {
      if (entity is File && entity.fileExtension == 'dart') {
        var entityStat = await entity.stat();

        var modificationTime = entityStat.modified;

        var relativePath = relative(entity.path, from: _projectPath);

        fileLogs
            .add(FileLog(FileLogType.source, relativePath, modificationTime));
      }
    }

    return fileLogs;
  }
}
