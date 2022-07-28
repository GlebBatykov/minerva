part of minerva_cli;

class CompileCLICommand extends CLICommand<List<FileLog>> {
  final String projectPath;

  final String mode;

  final String compileType;

  CompileCLICommand(this.projectPath, this.mode, this.compileType);

  @override
  Future<List<FileLog>> run() async {
    print('Compilation of the project...');

    var entryPointFilePath = '$projectPath/lib/main.dart';

    var entryPointFile = File.fromUri(Uri.file(entryPointFilePath));

    if (await entryPointFile.exists()) {
      await GetDependenciesCLICommand(projectPath).run();

      await _compile(entryPointFilePath);

      print('Compilation of the project is completed...');

      return await _createFileLogs();
    } else {
      throw CLICommandException(
          message: 'Entry point file not exist by path: $entryPointFilePath.');
    }
  }

  Future<void> _compile(String entryPointFilePath) async {
    var compileDirectoryPath = '$projectPath/build/$mode/bin';

    await Directory.fromUri(Uri.directory(compileDirectoryPath))
        .create(recursive: true);

    late Process process;

    if (compileType == 'AOT') {
      process = await _startCompileExecutableFile(
          entryPointFilePath, compileDirectoryPath);
    } else {
      process =
          await _startCompileSnapshot(entryPointFilePath, compileDirectoryPath);
    }

    process.stdout.listen((event) => stdout.add(event));
    process.stderr.listen((event) => stdout.add(event));

    await process.exitCode;
  }

  Future<Process> _startCompileExecutableFile(
      String entryPointFilePath, String compileDirectoryPath) async {
    return await Process.start('dart', [
      'compile',
      'exe',
      entryPointFilePath,
      '-o',
      '$compileDirectoryPath/main'
    ]);
  }

  Future<Process> _startCompileSnapshot(
      String entryPointFilePath, String compileDirectoryPath) async {
    return await Process.start('dart', [
      'compile',
      'kernel',
      entryPointFilePath,
      '-o',
      '$compileDirectoryPath/main.dill'
    ]);
  }

  Future<List<FileLog>> _createFileLogs() async {
    var libDirectory = Directory.fromUri(Uri.directory('$projectPath/lib'));

    var fileLogs = <FileLog>[];

    for (var entity in await libDirectory.list(recursive: true).toList()) {
      if (entity is File && entity.fileExtension == 'dart') {
        var entityStat = await entity.stat();

        var modificationTime = entityStat.modified;

        fileLogs.add(FileLog(
            FileLogType.source, entity.absolute.path, modificationTime));
      }
    }

    return fileLogs;
  }
}
