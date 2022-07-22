part of minerva_cli;

class RunCommand extends Command {
  @override
  String get name => 'run';

  @override
  String get description => 'Run Minerva server.';

  @override
  String get usage => '''
    -d  --directory points to the project directory.
    -m  --mode      sets the project build mode. Possible values: debug (default), release.
  ''';

  RunCommand() {
    argParser.addOption('directory',
        abbr: 'd', defaultsTo: Directory.current.path);
    argParser.addOption('mode',
        abbr: 'm', defaultsTo: 'debug', allowed: ['debug', 'release']);
  }

  @override
  Future<void> run() async {
    var results = argResults!;

    var directoryPath = results['directory'];

    var mode = results['mode'];

    var appSettingFile =
        File.fromUri(Uri.file('$directoryPath/appsetting.json'));

    if (!await appSettingFile.exists()) {
      usageException('Current directory not exist appsetting.json file.');
    }

    var setting = jsonDecode(await appSettingFile.readAsString())[mode];

    if (setting == null) {
      usageException(
          'Setting for $mode mode is not exist in appsetting.json file.');
    }

    var compileType = setting['compile-type'] ?? 'AOT';

    late Process appProcess;

    if (compileType == 'AOT') {
      try {
        await _buildAOT();
      } catch (object, stackTrace) {
        print(object);

        print(stackTrace);

        usageException(
            'Incorrect project build. Use the "minerva clear" command to clear the build.');
      }

      appProcess =
          await Process.start('$directoryPath/build/$mode/bin/main', []);
    } else {
      appProcess =
          await Process.start('dart', ['$directoryPath/lib/main.dart']);
    }

    appProcess.stdout.pipe(stdout);
    appProcess.stderr.pipe(stdout);

    await appProcess.exitCode;
  }

  Future<void> _buildAOT() async {
    var results = argResults!;

    var directoryPath = results['directory'];

    var mode = results['mode'];

    var detailsFile =
        File.fromUri(Uri.file('$directoryPath/build/$mode/details.json'));

    var isNeedBuild = await _isNeedBuild(detailsFile);

    if (isNeedBuild) {
      var buildProcess = await Process.start(
          'minerva', ['build', '-d', directoryPath, '-m', mode]);

      buildProcess.stdout.pipe(stdout);
      buildProcess.stderr.pipe(stdout);

      await buildProcess.exitCode;

      print('');
    }
  }

  Future<bool> _isNeedBuild(File detailsFile) async {
    var detailsFileExists = await detailsFile.exists();

    if (!detailsFileExists) {
      return true;
    }

    var details =
        jsonDecode(await detailsFile.readAsString()) as Map<String, dynamic>;

    if (!details.containsKey('fileLogs')) {
      return true;
    }

    var directoryPath = argResults!['directory'];

    var libDirectory = Directory.fromUri(Uri.directory('$directoryPath/lib'));

    var dartFiles = (await libDirectory.list(recursive: true).toList())
        .whereType<File>()
        .where((element) => element.fileExtension == 'dart');

    var fileLogs = (details['fileLogs'] as List).cast<Map<String, dynamic>>();

    if (dartFiles.length < fileLogs.length) {
      return true;
    }

    for (var fileLog in fileLogs) {
      var files = dartFiles
          .where((element) => element.absolute.path == fileLog['path']);

      if (files.isEmpty) {
        return true;
      }

      var file = files.first;

      var fileStat = await file.stat();

      if (fileStat.modified
          .isAfter(DateTime.parse(fileLog['modificationTime']))) {
        return true;
      }
    }

    return false;
  }
}
