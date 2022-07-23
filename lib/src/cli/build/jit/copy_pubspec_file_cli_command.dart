part of minerva_cli;

class CopyPubSpecFileCLICommand extends CLICommand<FileLog> {
  final String projectPath;

  final String mode;

  CopyPubSpecFileCLICommand(this.projectPath, this.mode);

  @override
  Future<FileLog> run() async {
    var pubSpecFilePath = '$projectPath/pubspec.yaml';

    var pubSpecFile = File.fromUri(Uri.file(pubSpecFilePath));

    if (!await pubSpecFile.exists()) {
      throw CLICommandException(
          message: 'File pubspec.yaml not exist by path: $pubSpecFilePath.');
    }

    var buildPubSpecFile =
        File.fromUri(Uri.file('$projectPath/build/$mode/pubspec.yaml'));

    await buildPubSpecFile.create(recursive: true);

    await buildPubSpecFile.writeAsBytes(await pubSpecFile.readAsBytes());

    var pubSpecFileStat = await pubSpecFile.stat();

    var fileLog = FileLog(pubSpecFilePath, pubSpecFileStat.modified);

    return fileLog;
  }
}
