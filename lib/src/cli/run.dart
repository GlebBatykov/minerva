part of minerva_cli;

class Run extends Command {
  @override
  String get name => 'run';

  @override
  String get description => 'Run Minerva server.';

  @override
  String get usage => '''
    -d  --directory points to the project directory.
    -m  --mode      sets the project build mode. Possible values: debug (default), release.
  ''';

  Run() {
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

    if (await appSettingFile.exists()) {
      var setting = jsonDecode(await appSettingFile.readAsString())[mode];

      if (setting != null) {
        var compileType = setting['compileType'] ?? 'AOT';

        late Process applicationProcess;

        if (compileType == 'AOT') {
          try {
            await _buildAOT();
          } catch (_) {
            usageException(
                'Incorrect project build. Use the "minerva clear" command to clear the build.');
          }

          applicationProcess =
              await Process.start('$directoryPath/build/$mode/bin/main', []);
        } else {
          var entryPointPath = setting['entry-point'] ?? 'lib/startup.dart';

          applicationProcess =
              await Process.start('dart', ['$directoryPath/$entryPointPath']);
        }

        applicationProcess.stdout.listen((event) => stdout.add(event));

        await applicationProcess.exitCode;
      } else {
        usageException(
            'Setting for $mode mode is not exist in appsetting.json file.');
      }
    } else {
      usageException('Current directory not exist appsetting.json file.');
    }
  }

  Future<void> _buildAOT() async {
    var results = argResults!;

    var directoryPath = results['directory'];

    var mode = results['mode'];

    var detailsFile =
        File.fromUri(Uri.file('$directoryPath/build/$mode/details.json'));

    if (await _isNeedBuild(detailsFile)) {
      var buildProcess = await Process.start(
          'minerva', ['build', '-d', directoryPath, '-m', mode]);

      buildProcess.stdout.listen((event) => stdout.add(event));

      await buildProcess.exitCode;

      stdout.writeln();
    }
  }

  Future<bool> _isNeedBuild(File detailsFile) async {
    var detailsFileExists = await detailsFile.exists();

    if (detailsFileExists) {
      var details =
          jsonDecode(await detailsFile.readAsString()) as Map<String, dynamic>;

      if (details.containsKey('numbersOfFiles') &&
          details.containsKey('fileLogs')) {
        var directoryPath = argResults!['directory'];

        var libDirectory =
            Directory.fromUri(Uri.directory('$directoryPath/lib'));

        var dartFiles = (await libDirectory.list(recursive: true).toList())
            .where(
                (element) => element is File && element.fileExtension == 'dart')
            .cast<File>();

        if (dartFiles.length != details['numbersOfFiles']) {
          return true;
        }

        var fileLogs =
            (details['fileLogs'] as List).cast<Map<String, dynamic>>();

        for (var fileLog in fileLogs) {
          var files =
              dartFiles.where((element) => element.path == fileLog['path']);

          if (files.isNotEmpty) {
            var file = files.first;

            var fileStat = await file.stat();

            if (fileStat.modified
                .isAfter(DateTime.parse(fileLog['modificationTime']))) {
              return true;
            }
          } else {
            return true;
          }
        }
      } else {
        return true;
      }
    } else {
      return true;
    }

    return false;
  }
}
