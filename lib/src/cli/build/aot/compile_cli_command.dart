part of minerva_cli;

class CompileCLICommand extends CLICommand<List<FileLog>> {
  final String projectPath;

  final String mode;

  CompileCLICommand(this.projectPath, this.mode);

  @override
  Future<List<FileLog>> run() async {
    var entryPointFilePath = '$projectPath/lib/main.dart';

    var entryPointFile = File.fromUri(Uri.file(entryPointFilePath));

    if (await entryPointFile.exists()) {
      await _compile(entryPointFilePath);

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

    var process = await Process.start('dart', [
      'compile',
      'exe',
      entryPointFilePath,
      '-o',
      '$compileDirectoryPath/main'
    ]);

    process.stdout.listen((event) => stdout.add(event));
    process.stderr.listen((event) => stdout.add(event));

    await process.exitCode;
  }

  Future<List<FileLog>> _createFileLogs() async {
    var libDirectory = Directory.fromUri(Uri.directory('$projectPath/lib'));

    var fileLogs = <FileLog>[];

    for (var entity in await libDirectory.list(recursive: true).toList()) {
      if (entity is File && entity.fileExtension == 'dart') {
        var entityStat = await entity.stat();

        var modificationTime = entityStat.modified;

        fileLogs.add(FileLog(entity.absolute.path, modificationTime));
      }
    }

    return fileLogs;
  }
}
