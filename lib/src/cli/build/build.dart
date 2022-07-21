part of minerva_cli;

class Build extends Command {
  @override
  String get name => 'build';

  @override
  String get description => 'Build project.';

  @override
  String get usage => '''
    -d  --directory points to the project directory.
    -m  --mode      sets the project build mode. Possible values: debug (default), release.
  ''';

  Build() {
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

        if (compileType == 'AOT') {
          try {
            var entryPointPath = setting['entry-point'] ?? 'lib/startup.dart';

            await CompileCommand(directoryPath, entryPointPath, mode).run();
          } on CLICommandException catch (object) {
            usageException(object.message);
          }
        }
      } else {
        usageException(
            'Setting for $mode mode is not exist in appsetting.json file.');
      }
    } else {
      usageException('Current directory not exist appsetting.json file.');
    }
  }
}
