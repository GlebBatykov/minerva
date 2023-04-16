part of minerva_cli;

class ClearCommand extends Command {
  @override
  String get name => 'clear';

  @override
  String get description => 'Clear project build files.';

  @override
  String get usage => '''
    -$directoryOptionAbbr  --$directoryOptionName points to the project directory.
  ''';

  late final String _directoryPath;

  ClearCommand() {
    argParser.addOption(
      directoryOptionName,
      abbr: directoryOptionAbbr,
      defaultsTo: Directory.current.path,
    );
  }

  @override
  Future<void> run() async {
    final args = argResults!;

    _directoryPath = Directory.fromUri(Uri.directory(
      args[directoryOptionName],
      windows: Platform.isWindows,
    )).absolute.path;

    final buildDirectoryPath = '$_directoryPath/build';

    print('Cleaning the build...');

    await ClearDirectoryCLICommand(buildDirectoryPath).run();

    await DeleteTestAppSettingCLICommand(_directoryPath).run();

    print('The build cleanup is complete...');
  }
}
