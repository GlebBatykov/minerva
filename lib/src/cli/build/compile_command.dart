part of minerva_cli;

class CompileCommand extends CLICommand<void> {
  final String projectPath;

  final String entryPointPath;

  final String mode;

  CompileCommand(this.projectPath, this.entryPointPath, this.mode);

  @override
  Future<void> run() async {
    var entryPointFilePath = '$projectPath/$entryPointPath';

    var entryPointFile = File.fromUri(Uri.file(entryPointFilePath));

    if (await entryPointFile.exists()) {
      await _compile(entryPointFilePath);

      await _createDetails();
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

    await process.stdout.pipe(stdout);

    await process.exitCode;
  }

  Future<void> _createDetails() async {
    var detailsFile =
        File.fromUri(Uri.file('$projectPath/build/$mode/details.json'));

    var libDirectory = Directory.fromUri(Uri.directory('$projectPath/lib'));

    var fileLogs = <Map<String, dynamic>>[];

    for (var entity in await libDirectory.list(recursive: true).toList()) {
      if (entity is File && entity.fileExtension == 'dart') {
        var entityStat = await entity.stat();

        var modificationTime = entityStat.modified;

        fileLogs.add({
          'path': entity.path,
          'modificationTime': modificationTime.toString()
        });
      }
    }

    var details = <String, dynamic>{'fileLogs': fileLogs};

    var json = jsonEncode(details);

    await detailsFile.writeAsString(json);
  }
}
