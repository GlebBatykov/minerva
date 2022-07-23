part of minerva_cli;

class ClearCommand extends Command {
  @override
  String get name => 'clear';

  @override
  String get description => 'Clear project build files.';

  @override
  String get usage => '''
    -d  --directory points to the project directory.
  ''';

  late final String _directoryPath;

  ClearCommand() {
    argParser.addOption('directory',
        abbr: 'd', defaultsTo: Directory.current.path);
  }

  @override
  Future<void> run() async {
    _directoryPath =
        Directory.fromUri(Uri.parse(argResults!['directory'])).absolute.path;

    var buildDirectoryPath = '$_directoryPath/build';

    await ClearDirectoryCLICommand(buildDirectoryPath).run();
  }
}
