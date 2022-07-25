part of minerva_cli;

class RunApplicationCLICommand extends CLICommand<Process> {
  final String projectPath;

  final String mode;

  RunApplicationCLICommand(this.projectPath, this.mode);

  @override
  Future<Process> run() async {
    var appSettingFile = File.fromUri(Uri.file('$projectPath/appsetting.json'));

    if (!await appSettingFile.exists()) {
      throw CLICommandException(
          message: 'Current directory not exist appsetting.json file.');
    }

    var setting = jsonDecode(await appSettingFile.readAsString())[mode];

    if (setting == null) {
      throw CLICommandException(
          message:
              'Setting for $mode mode is not exist in appsetting.json file.');
    }

    await _runBuild();

    var compileType = setting['compile-type'] ?? 'AOT';

    late Process appProcess;

    if (compileType == 'AOT') {
      appProcess = await _runAOT();
    } else {
      appProcess = await _runJIT();
    }

    return appProcess;
  }

  Future<void> _runBuild() async {
    var buildProcess = await Process.start(
        'minerva', ['build', '-d', projectPath, '-m', mode]);

    buildProcess.stdout.listen((event) => stdout.add(event));
    buildProcess.stderr.listen((event) => stdout.add(event));

    await buildProcess.exitCode;

    stdout.writeln();
  }

  Future<Process> _runAOT() async {
    var entryPointFilePath = '$projectPath/build/$mode/bin/main';

    var entryPointFile = File.fromUri(Uri.file(entryPointFilePath));

    if (await entryPointFile.exists()) {
      return await Process.start(entryPointFilePath, []);
    } else {
      throw CLICommandException(
          message: 'Entry point not found by path: $entryPointFilePath.');
    }
  }

  Future<Process> _runJIT() async {
    var entryPointFilePath = '$projectPath/build/$mode/bin/main.dill';

    var entryPointFile = File.fromUri(Uri.file(entryPointFilePath));

    if (await entryPointFile.exists()) {
      return await Process.start('dart', [entryPointFilePath]);
    } else {
      throw CLICommandException(
          message: 'Entry point not found by path: $entryPointFilePath.');
    }
  }
}
