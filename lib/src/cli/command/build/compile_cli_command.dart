part of minerva_cli;

class CompileCLICommand extends CLICommand<List<FileLog>> {
  final String projectPath;

  final BuildMode mode;

  final CompileType compileType;

  CompileCLICommand(this.projectPath, this.mode, this.compileType);

  @override
  Future<List<FileLog>> run() async {
    print('Compilation of the project...');

    final entryPointFilePath = '$projectPath/lib/main.dart';

    final entryPointFile =
        File.fromUri(Uri.file(entryPointFilePath, windows: Platform.isWindows));

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
    final compileDirectoryPath = '$projectPath/build/$mode/bin';

    final compileDirectory = Directory.fromUri(
        Uri.directory(compileDirectoryPath, windows: Platform.isWindows));

    if (await compileDirectory.exists()) {
      await compileDirectory.delete(recursive: true);
    }

    await compileDirectory.create(recursive: true);

    late Process process;

    if (compileType == CompileType.aot) {
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
      Platform.isWindows
          ? '$compileDirectoryPath/main.exe'
          : '$compileDirectoryPath/main'
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
    final libDirectory = Directory.fromUri(
        Uri.directory('$projectPath/lib', windows: Platform.isWindows));

    final fileLogs =
        await FileLogCreater(projectPath).createSourceLogs(libDirectory);

    return fileLogs;
  }
}
