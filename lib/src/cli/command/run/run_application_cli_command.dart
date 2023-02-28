part of minerva_cli;

class RunApplicationCLICommand extends CLICommand<Process> {
  final String projectPath;

  final BuildMode mode;

  RunApplicationCLICommand(
    this.projectPath,
    this.mode,
  );

  @override
  Future<Process> run() async {
    final appSettingFile = File.fromUri(Uri.file(
      '$projectPath/appsetting.json',
      windows: Platform.isWindows,
    ));

    if (!await appSettingFile.exists()) {
      throw CLICommandException(
          message: 'Current directory not exist appsetting.json file.');
    }

    final appSetting =
        AppSetting.fromJson(jsonDecode(await appSettingFile.readAsString()));

    final buildSetting = _getBuildSetting(
      appSetting,
      mode,
    );

    if (buildSetting == null) {
      throw CLICommandException(
          message:
              'Setting for $mode mode is not exist in appsetting.json file.');
    }

    await _runBuild();

    final compileType = buildSetting.compileType ?? CompileType.aot;

    late final Process appProcess;

    if (compileType == CompileType.aot) {
      appProcess = await _runAOT();
    } else {
      appProcess = await _runJIT();
    }

    return appProcess;
  }

  BuildAppSetting? _getBuildSetting(
    AppSetting appSetting,
    BuildMode mode,
  ) {
    if (mode == BuildMode.debug) {
      return appSetting.debug;
    } else {
      return appSetting.release;
    }
  }

  Future<void> _runBuild() async {
    final buildProcess = await Process.start(
        'minerva', ['build', '-d', projectPath, '-m', mode.toString()],
        runInShell: true);

    buildProcess.stdout.listen((e) => stdout.add(e));
    buildProcess.stderr.listen((e) => stdout.add(e));

    await buildProcess.exitCode;

    stdout.writeln();
  }

  Future<Process> _runAOT() async {
    final entryPointFilePath = Platform.isWindows
        ? '$projectPath/build/$mode/bin/main.exe'
        : '$projectPath/build/$mode/bin/main';

    final entryPointFile = File.fromUri(Uri.file(
      entryPointFilePath,
      windows: Platform.isWindows,
    ));

    if (await entryPointFile.exists()) {
      return await Process.start(entryPointFilePath, []);
    } else {
      throw CLICommandException(
          message: 'Entry point not found by path: $entryPointFilePath.');
    }
  }

  Future<Process> _runJIT() async {
    final entryPointFilePath = '$projectPath/build/$mode/bin/main.dill';

    final entryPointFile = File.fromUri(Uri.file(
      entryPointFilePath,
      windows: Platform.isWindows,
    ));

    if (await entryPointFile.exists()) {
      return await Process.start('dart', [entryPointFilePath]);
    } else {
      throw CLICommandException(
          message: 'Entry point not found by path: $entryPointFilePath.');
    }
  }
}
