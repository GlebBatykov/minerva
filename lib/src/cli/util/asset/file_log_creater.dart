part of minerva_cli;

class FileLogCreater {
  final String _projectPath;

  FileLogCreater(String projectPath) : _projectPath = projectPath;

  Future<List<FileLog>> createAssetsLogs(List<File> assets) async {
    final fileLogs = <FileLog>[];

    for (final file in assets) {
      fileLogs.add(await createAssetLog(file));
    }

    return fileLogs;
  }

  Future<FileLog> createAssetLog(File file) async {
    final stat = await file.stat();

    final relativePath = relative(
      file.path,
      from: _projectPath,
    );

    return FileLog(
      type: FileLogType.asset,
      path: relativePath,
      modificationTime: stat.modified,
    );
  }

  Future<FileLog> createAppSettingLog(File file) async {
    final appSettingFileStat = await file.stat();

    final modificationTime = appSettingFileStat.modified;

    final relativePath = relative(
      file.path,
      from: _projectPath,
    );

    final fileLog = FileLog(
      type: FileLogType.appsetting,
      path: relativePath,
      modificationTime: modificationTime,
    );

    return fileLog;
  }

  Future<List<FileLog>> createSourceLogs(Directory libDirectory) async {
    final fileLogs = <FileLog>[];

    final entitiesStream = libDirectory.list(
      recursive: true,
    );

    final entities = await entitiesStream.toList();

    for (final entity in entities) {
      if (entity is File && entity.fileExtension == 'dart') {
        final entityStat = await entity.stat();

        final modificationTime = entityStat.modified;

        final relativePath = relative(
          entity.path,
          from: _projectPath,
        );

        fileLogs.add(FileLog(
          type: FileLogType.source,
          path: relativePath,
          modificationTime: modificationTime,
        ));
      }
    }

    return fileLogs;
  }
}
